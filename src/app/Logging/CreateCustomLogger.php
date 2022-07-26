<?php

namespace App\Logging;

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\JsonFormatter;
use App\Logging\Processor\CustomProcessor;

class CreateCustomLogger
{
    /**
     * Create a custom Monolog instance.
     *
     * @param  array  $config
     * @return \Monolog\Logger
     */
    public function __invoke(array $config)
    {
        $log = new Logger('json-log');
        $formatter = new JsonFormatter();
        $environment = App()->environment();
        $stream = new StreamHandler($config['path'], $config['level']);
        $stream->setFormatter($formatter);
        $custom_processor = new CustomProcessor();
        $stream->pushProcessor($custom_processor);
        $log->pushHandler($stream);
        return $log;

    }
}


