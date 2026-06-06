import {
  IsNotEmpty,
  IsString,
  ValidationArguments,
  ValidationOptions,
  registerDecorator,
} from 'class-validator';

function IsRedirectUri(validationOptions?: ValidationOptions) {
  return (object: object, propertyName: string) => {
    registerDecorator({
      name: 'isRedirectUri',
      target: object.constructor,
      propertyName,
      options: validationOptions,
      validator: {
        validate(value: unknown) {
          if (typeof value !== 'string' || value.trim().length === 0) {
            return false;
          }

          try {
            const uri = new URL(value.trim());
            return uri.protocol.length > 1 && uri.host.length > 0;
          } catch {
            return false;
          }
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must be a valid redirect URI.`;
        },
      },
    });
  };
}

export class CreateAppDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsRedirectUri({ message: 'A valid redirect URI is required.' })
  @IsNotEmpty()
  redirectUri!: string;
}
