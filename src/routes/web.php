<?php

use Illuminate\Support\Facades\Route;

use Illuminate\Support\Facades\Log;

use App\Http\Controllers\ImageController;
/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return redirect('image-upload');
    // return view('welcome');
});

Route::get('/healthcheck', function(){
    Log::debug('Accessing to the healthcheck url');
    return ["app_name"=>config("app.name") ,"env"=>config("app.env"), "version" => "0.0.5"];
});


Route::get('image-upload', [ImageController::class, 'index'])->name('image.index');
Route::post('image-upload', [ImageController::class, 'upload'])->name('image.upload');