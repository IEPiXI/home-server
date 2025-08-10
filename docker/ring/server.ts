import { RingApi, RingIntercom, Location } from "ring-client-api";
import express, { Request, Response, NextFunction } from "express";
import { promises as fs } from "fs";
import path from "path";
import dotenv from "dotenv";
import chokidar from "chokidar";

const ENV_PATH = path.resolve(process.cwd(), ".env");

class RingServer {
    private app = express();
    private location: Location | undefined;
    private intercom: RingIntercom | undefined;
    private isRingReady = false;
    private watcher: chokidar.FSWatcher | undefined;
    private unlockPassword?: string;
    private locationName?: string;
    private intercomName?: string;
    private isInternalUpdate = false;
    private readonly port: number;

    constructor(port: number = 3000) {
        this.port = port;
        this.setupRoutes();
        this.initializeApp();
    }

    private async initializeApp(): Promise<void> {
        this.app.listen(this.port, () => {
            console.log(`🚀 Unlock server is running on port ${this.port}.`);
            console.log("   Waiting for Ring credentials to become available...");
        });

        this.initializeOrWatchEnvFile();
    }

    private async initializeOrWatchEnvFile(): Promise<void> {
        console.log("Attempting to initialize Ring connection...");
        const success = await this.connectToRing();

        if (success) {
            return;
        }

        console.log(`[File Watcher] Watching for changes to: ${ENV_PATH}`);
        this.watcher = chokidar.watch(ENV_PATH, {
            ignoreInitial: true,
            persistent: true,
        });

        this.watcher.on("add", this.handleEnvFileChange);
        this.watcher.on("change", this.handleEnvFileChange);
    }

    private handleEnvFileChange = async (filePath: string): Promise<void> => {
        if (this.isInternalUpdate) return;

        console.log(`[File Watcher] Detected change in ${filePath}. Reloading configuration...`);
        const success = await this.connectToRing();

        if (success && this.watcher) {
            console.log("[File Watcher] Connection successful. Stopping file watcher.");
            await this.watcher.close();
            this.watcher = undefined;
        }
    };

    private authenticate = (req: Request, res: Response, next: NextFunction) => {
        if (req.headers["authorization"] !== `Bearer ${this.unlockPassword}`) {
            return res.status(403).send("Forbidden: Incorrect or missing password");
        }
        return next();
    };

    private setupRoutes(): void {
        this.app.get("/unlock", this.authenticate, async (req: Request, res: Response) => {
            if (!this.isRingReady || !this.intercom) {
                return res.status(503).send("Service Unavailable: Ring Intercom is not connected yet.");
            }
            try {
                await this.intercom.unlock();
                res.send("✅ Intercom unlocked successfully.");
            } catch (error) {
                console.error("Failed to unlock intercom:", error);
                res.status(500).send("Failed to unlock intercom.");
            }
        });
    }

    private async connectToRing(): Promise<boolean> {
        dotenv.config({ path: ENV_PATH, override: true });
        this.unlockPassword = process.env.UNLOCK_PASSWORD;
        this.locationName = process.env.LOCATION_NAME;
        this.intercomName = process.env.INTERCOM_NAME;

        const refreshToken = process.env.RING_REFRESH_TOKEN;
        
        
        if (!refreshToken) {
            console.log("Could not find RING_REFRESH_TOKEN. Waiting for it to be added...");
            return false;
        }

        try {
            const ringApi = new RingApi({ refreshToken, debug: false });

            ringApi.onRefreshTokenUpdated.subscribe(async ({ newRefreshToken, oldRefreshToken }) => {
                if (!oldRefreshToken) return;

                console.log("Refresh Token Updated, saving to .env file...");
                const currentConfig = await fs.readFile(ENV_PATH, "utf-8");
                const updatedConfig = currentConfig.replace(
                    `RING_REFRESH_TOKEN=${oldRefreshToken}`,
                    `RING_REFRESH_TOKEN=${newRefreshToken}`
                );

                this.isInternalUpdate = true;
                await fs.writeFile(ENV_PATH, updatedConfig);
                console.log("✅ New refresh token saved.");

                setTimeout(() => {
                    this.isInternalUpdate = false;
                }, 1000);
            });

            const locations = await ringApi.getLocations();
            this.location = locations.find((loc) => loc.name === this.locationName);
            if (!this.location) {
                throw new Error(`Location with name "${this.locationName}" not found.`);
            }

            this.intercom = this.location.intercoms.find((intercom) => intercom.name === this.intercomName);
            if (!this.intercom) {
                throw new Error(`Intercom "${this.intercomName}" not found in location "${this.locationName}.`);
            }

            console.log(`✅ Successfully connected to Intercom: ${this.intercom.name}`);
            this.isRingReady = true;
            return true;
        } catch (error: any) {
            console.error("❌ Failed to connect to Ring API:", error.message);
            this.isRingReady = false;
            if (error.message.includes("Refresh token is not valid")) {
                console.error("The stored refresh token is invalid. Please run the auth script again.");
            }
            return false;
        }
    }
}

new RingServer(3000);
