import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<{
      status: (code: number) => { json: (body: unknown) => void };
    }>();
    const request = ctx.getRequest<{ url?: string; method?: string }>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const payload =
      exception instanceof HttpException ? exception.getResponse() : null;

    const message = this.extractMessage(payload) ?? 'Internal server error';

    response.status(status).json({
      success: false,
      error: {
        code: this.statusCodeToErrorCode(status),
        message,
        details: typeof payload === 'object' ? payload : undefined,
      },
      meta: {
        timestamp: new Date().toISOString(),
        method: request.method,
        path: request.url,
      },
    });
  }

  private extractMessage(payload: unknown): string | null {
    if (!payload) return null;
    if (typeof payload === 'string') return payload;

    if (typeof payload === 'object') {
      const candidate = (payload as Record<string, unknown>).message;
      if (typeof candidate === 'string') return candidate;

      if (Array.isArray(candidate) && candidate.length > 0) {
        return String(candidate[0]);
      }
    }

    return null;
  }

  private statusCodeToErrorCode(status: number): string {
    const map: Record<number, string> = {
      400: 'BAD_REQUEST',
      401: 'UNAUTHORIZED',
      403: 'FORBIDDEN',
      404: 'NOT_FOUND',
      409: 'CONFLICT',
      422: 'UNPROCESSABLE_ENTITY',
      429: 'TOO_MANY_REQUESTS',
      500: 'INTERNAL_SERVER_ERROR',
    };

    return map[status] ?? 'UNKNOWN_ERROR';
  }
}
