import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ILogger } from '../../core/ports/logger.interface';

@Injectable()
export class SlackLoggerAdapter implements ILogger {
  private readonly webhookUrl: string | undefined;
  private readonly environment: string;

  private readonly nestLogger = new Logger('ToroPass');

  constructor(private configService: ConfigService) {
    this.webhookUrl = this.configService.get<string>('SLACK_WEBHOOK_URL');
    this.environment =
      this.configService.get<string>('NODE_ENV') || 'development';
  }

  logInfo({
    message,
    slack = false,
  }: {
    message: string;
    slack?: boolean;
  }): Promise<void> {
    this.nestLogger.log(message);

    if (slack) {
      const log = `🟢 *[INFO]*\n\`${this.environment}\`\n*Message:* ${message}`;
      void this.sendToSlack(log).catch(() => {});
    }

    return Promise.resolve();
  }

  logAlert({
    message,
    error,
    slack = true,
  }: {
    message: string;
    error?: any;
    slack?: boolean;
  }): Promise<void> {
    const errorDetail =
      error instanceof Error
        ? error.stack || error.message
        : String(error || 'N/A');

    this.nestLogger.error(message, errorDetail);

    if (slack) {
      const log = `🚨 *[ALERT]*\n\`${this.environment}\`\n*Message:* ${message}\n*Error:* \`${errorDetail}\``;
      void this.sendToSlack(log).catch(() => {});
    }

    return Promise.resolve();
  }

  private async sendToSlack(payloadText: string): Promise<void> {
    if (!this.webhookUrl) {
      this.nestLogger.warn('Slack Webhook URL is missing. Message not sent.');
      return;
    }

    try {
      await fetch(this.webhookUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: payloadText }),
      });
    } catch (error: unknown) {
      const errorMessage = this.formatError(error);
      this.nestLogger.error('Failed to send payload to Slack', errorMessage);
    }
  }

  private formatError(error: unknown): string {
    if (error instanceof Error) return error.stack || error.message;
    if (typeof error === 'string') return error;

    try {
      return JSON.stringify(error) || 'Unknown Slack delivery error';
    } catch {
      return 'Unknown Slack delivery error';
    }
  }
}
