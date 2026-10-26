<?php

namespace App\Contracts;

final class FcmDeliveryResult
{
    public function __construct(public readonly bool $accepted, public readonly ?string $errorCategory = null) {}

    public static function unavailable(): self
    {
        return new self(false, 'provider_unavailable');
    }
}
