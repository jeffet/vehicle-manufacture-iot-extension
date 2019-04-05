import { newLogger } from 'fabric-shim';
import * as getParams from 'get-params';
import 'reflect-metadata';

const logger = newLogger('ANNOTATIONS');

export function NotRequired(target: any, propertyKey: string, descriptor: number) {
    if (typeof propertyKey === 'undefined') {
        propertyKey = 'constructor';
        target = target.prototype;
    }

    const existingParams = Reflect.getMetadata('contract:function', target, propertyKey) ||
        getParams(target[propertyKey]);

    logger.info('EXISTING PARAMS' + JSON.stringify(existingParams) + 'DESCRIPTOR ' + descriptor);

    existingParams[descriptor] = (existingParams[descriptor] as string).endsWith('?') ?
        existingParams[descriptor] : existingParams[descriptor] + '?';

    Reflect.defineMetadata('contract:function', existingParams, target, propertyKey);

    logger.info('@NotRequired - ' + JSON.stringify(existingParams));
}