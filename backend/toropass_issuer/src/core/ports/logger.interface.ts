export const LOGGER_PORT = 'LOGGER_PORT';

export interface ILogger {
  logInfo(options: { message: string; slack?: boolean }): Promise<void>;
  logAlert(options: {
    message: string;
    error?: unknown;
    slack?: boolean;
  }): Promise<void>;
}
