<?php

namespace App\Providers;

use App\Repositories\Contracts\UserRepository;
use App\Repositories\Eloquent\UserRepository as EloquentUserRepository;
use Illuminate\Support\ServiceProvider;
use App\Contracts\FaceVerificationInterface;
use App\Services\UnavailableFaceVerificationProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;
use App\Contracts\FcmDeliveryInterface;
use App\Services\UnavailableFcmProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(UserRepository::class, EloquentUserRepository::class);
        $this->app->singleton(FaceVerificationInterface::class, UnavailableFaceVerificationProvider::class);
        $this->app->singleton(FcmDeliveryInterface::class, UnavailableFcmProvider::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('api', fn ($request) => Limit::perMinute(60)->by($request->user()?->id ?: $request->ip()));
    }
}
