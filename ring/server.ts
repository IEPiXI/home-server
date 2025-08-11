import { RingApi, RingIntercom } from "ring-client-api";
import express, { Request, Response, NextFunction } from "express";
import { promises as fs } from "fs";
import path from "path";
import dotenv from "dotenv";
import chokidar from "chokidar";

const ENV_PATH = path.resolve(process.cwd(), ".env");

interface AppConfig {
    refreshToken: string;
    unlockPassword: string;
    locationName: string;
    intercomName: string;
}

class RingServer {
    private app = express();
    private intercom?: RingIntercom;
    private config?: AppConfig;
    private watcher?: chokidar.FSWatcher;

    private isInternalEnvUpdate = false;
    private isInitializing = false;
    private debounceTimeout?: NodeJS.Timeout;

    private readonly port: number;

    constructor(port = 3000) {
        this.port = port;
        this.setupRoutes();
    }

    public async start(): Promise<void> {
        this.app.listen(this.port, () => {
            console.log(`🚀 Unlock server is running on port ${this.port}.`);
        });
        await this.initialize();
    }

    private async initialize(): Promise<void> {
        if (this.isInitializing) {
            console.log("🟡 Initialization already in progress. Skipping.");
            return;
        }
        this.isInitializing = true;
        console.log("🔍 Initializing Ring connection...");

        try {
            this.loadAndValidateConfig();
            await this.initializeRingConnection();
            await this.stopFileWatcher();
        } catch (error: any) {
            console.warn(`❌ Initialization failed: ${error.message}`);
            if (!this.intercom) {
                this.watchEnvFile();
            }
        } finally {
            this.isInitializing = false;
        }
    }

    private loadAndValidateConfig(): void {
        dotenv.config({ path: ENV_PATH, override: true });

        const requiredEnvVars = ["RING_REFRESH_TOKEN", "UNLOCK_PASSWORD", "LOCATION_NAME", "INTERCOM_NAME"];
        const missingVars = requiredEnvVars.filter((envVar) => !process.env[envVar]);
        if (missingVars.length > 0) {
            throw new Error(`Missing required environment variables: ${missingVars.join(", ")}`);
        }

        this.config = {
            refreshToken: process.env.RING_REFRESH_TOKEN!,
            unlockPassword: process.env.UNLOCK_PASSWORD!,
            locationName: process.env.LOCATION_NAME!,
            intercomName: process.env.INTERCOM_NAME!,
        };

        console.log("✅ Configuration loaded and validated.");
    }

    private async initializeRingConnection(): Promise<void> {
        if (!this.config) {
            throw new Error("Cannot connect to Ring without a valid configuration.");
        }

        try {
            const ringApi = new RingApi({
                refreshToken: this.config.refreshToken,
                debug: false,
            });

            ringApi.onRefreshTokenUpdated.subscribe(this.handleRefreshTokenUpdate);

            const locations = await ringApi.getLocations();
            const location = locations.find((loc) => loc.name === this.config!.locationName);
            if (!location) {
                throw new Error(`Location with name "${this.config.locationName}" not found.`);
            }

            this.intercom = location.intercoms.find((intercom) => intercom.name === this.config!.intercomName);
            if (!this.intercom) {
                throw new Error(
                    `Intercom "${this.config.intercomName}" not found in location "${this.config.locationName}".`
                );
            }

            console.log(`✅ Successfully connected to Intercom: ${this.intercom.name}`);
        } catch (error: any) {
            this.intercom = undefined;
            if (error.message.includes("Refresh token is not valid")) {
                error.message =
                    "The stored refresh token is invalid or expired. Please generate a new one using the auth script.";
            }
            throw new Error(`Failed to connect to Ring API: ${error.message}`);
        }
    }

    private async stopFileWatcher(): Promise<void> {
        if (this.watcher) {
            console.log("[File Watcher] Connection successful. Stopping file watcher.");
            await this.watcher.close();
            this.watcher = undefined;
        }
    }

    private watchEnvFile(): void {
        if (this.watcher) return;
        console.log(`[File Watcher] Watching for changes to: ${ENV_PATH}`);
        this.watcher = chokidar.watch(ENV_PATH, { ignoreInitial: true, persistent: true });
        this.watcher.on("add", this.handleEnvFileChange).on("change", this.handleEnvFileChange);
    }

    private handleEnvFileChange = (): void => {
        if (this.isInternalEnvUpdate) return;
        if (this.debounceTimeout) clearTimeout(this.debounceTimeout);

        this.debounceTimeout = setTimeout(async () => {
            console.log(`[File Watcher] Detected change in .env file. Re-initializing...`);
            await this.initialize();
        }, 500);
    };

    private handleRefreshTokenUpdate = async ({
        newRefreshToken,
        oldRefreshToken,
    }: {
        newRefreshToken: string;
        oldRefreshToken?: string;
    }) => {
        if (!oldRefreshToken || newRefreshToken === oldRefreshToken) return;

        console.log("Token updated. Saving new refresh token to .env file...");
        try {
            const currentEnv = await fs.readFile(ENV_PATH, "utf-8");

            let updateEnv: string;
            if (currentEnv.includes(`RING_REFRESH_TOKEN=${oldRefreshToken}`)) {
                updateEnv = currentEnv.replace(
                    `RING_REFRESH_TOKEN=${oldRefreshToken}`,
                    `RING_REFRESH_TOKEN=${newRefreshToken}`
                );
            } else {
                updateEnv = currentEnv + `\nRING_REFRESH_TOKEN=${newRefreshToken}`;
                console.warn("Could not find old refresh token in .env, appending new one.");
            }

            this.isInternalEnvUpdate = true;
            await fs.writeFile(ENV_PATH, updateEnv);
            console.log("✅ New refresh token saved.");

            if (this.config) this.config.refreshToken = newRefreshToken;

            setTimeout(() => {
                this.isInternalEnvUpdate = false;
            }, 1000);
        } catch (error) {
            console.error("❌ Failed to write new refresh token to .env file:", error);
            this.isInternalEnvUpdate = false;
        }
    };

    private authenticate = (req: Request, res: Response, next: NextFunction) => {
        const authHeader = req.headers["authorization"];
        if (!this.config || authHeader !== `Bearer ${this.config.unlockPassword}`) {
            return res.status(403).send("Forbidden: Incorrect or missing password.");
        }
        next();
    };

    private setupRoutes(): void {
        this.app.get("/unlock", this.authenticate, async (req: Request, res: Response) => {
            var message;
            if (!this.intercom) {
                message = "Service Unavailable: Ring Intercom is not ready";
                console.error("❌ " + message);
                return res.status(503).send(message);
            }
            try {
                await this.intercom.unlock();
                message = "Intercom unlocked successfully";
                console.log("✅ " + message);
                return res.send(message);
            } catch (error: any) {
                message = "Failed to unlock intercom:\n   ";
                if (error?.response?.statusCode === 422) {
                    message += "The device was unable to perform the action. Please check the ";
                    message += "intercom's status (e.g. battery, network connection, ...)";
                    console.error("❌ " + message);
                    return res.status(500).send(message);
                } else {
                    message += error.message;
                    console.error("❌ " + message);
                    return res.status(500).send("Failed to unlock intercom due to an unexpected error.");
                }
            }
        });
    }
}

const server = new RingServer(3000);
server.start();
