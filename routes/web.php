<?php

use Illuminate\Support\Facades\Route;

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
    return view('welcome');
});

/**
 * @internal   Just for a test
 * @deprecated Remove this routes group
 */
Route::prefix('test')->group(static function () {
    Route::get('/database', [\App\Http\Controllers\TestController::class, 'database'])
        ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class]);

    Route::get('/queue', [\App\Http\Controllers\TestController::class, 'queue'])
        ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class]);

    Route::any('/dump', [\App\Http\Controllers\TestController::class, 'dump'])
        ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class]);

    Route::post('/upload', [\App\Http\Controllers\TestController::class, 'upload'])
        ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class]);

    Route::get('/url', [\App\Http\Controllers\TestController::class, 'url'])
        ->withoutMiddleware([\App\Http\Middleware\VerifyCsrfToken::class]);
});
