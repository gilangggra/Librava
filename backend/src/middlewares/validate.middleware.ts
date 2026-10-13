import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

interface ValidationTargets {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export const validate = (schemas: ValidationTargets) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      if (schemas.body) {
        req.body = schemas.body.parse(req.body);
      }
      if (schemas.query) {
        const parsedQuery = schemas.query.parse(req.query) as any;
        for (const key of Object.keys(req.query)) {
          delete (req.query as any)[key];
        }
        Object.assign(req.query, parsedQuery);
      }
      if (schemas.params) {
        const parsedParams = schemas.params.parse(req.params) as any;
        for (const key of Object.keys(req.params)) {
          delete (req.params as any)[key];
        }
        Object.assign(req.params, parsedParams);
      }
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const issues = error.issues || (error as any).errors || [];
        const formattedErrors = issues.map((err: any) => ({
          field: err.path ? err.path.join('.') : '',
          message: err.message,
        }));

        res.status(400).json({
          success: false,
          message: issues[0]?.message || 'Data yang dikirim tidak valid.',
          errors: formattedErrors,
        });
        return;
      }

      next(error);
    }
  };
};
