<?php
/**
 * Created by PhpStorm.
 * User: mac
 * Date: 10/21/18
 * Time: 8:45 PM
 */

namespace App\Logging;


class ExecutionTime
{
     private $startTime;
     private $endTime;

     public function start(){
         $this->startTime = microtime(true);
     }
     public function end(){
         $this->endTime =  microtime(true);
     }
     public function diff(){
         return $this->endTime - $this->startTime;
     }
 }