<?php

namespace App\Providers;

use App\Contracts\FaceVerificationInterface;
use App\Contracts\FcmDeliveryInterface;
use App\Repositories\Contracts\UserRepository;
use App\Repositories\Eloquent\UserRepository as EloquentUserRepository;
use App\Services\UnavailableFaceVerificationProvider;
use App\Services\UnavailableFcmProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

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
