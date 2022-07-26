<?php

/*
 * This file is part of the Monolog package.
 *
 * (c) Jordi Boggiano <j.boggiano@seld.be>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace App\Logging\Processor;


/**
 * Adds a unique identifier into records
 *
 * @author Simon Mönch <sm@webfactory.de>
 */
class CustomProcessor
{
    private $app_name;
    private $environment;

    public function __construct()
    {

        $this->app_name = config('app.name');
        $this->environment = App()->environment();
    }

    public function __invoke(array $record)
    {

        $record['extra']['context'] = $record['context'];
        $record['context'] = [];
        $record['extra']['app_name'] = $this->app_name;
        $record['extra']['environment'] = $this->environment;

        return $record;
    }

    /**
     * @return string
     */
    public function get_app_name()
    {
        return $this->app_name;
    }


    public function get_environment()
    {
        return $this->environment;
    }

}
