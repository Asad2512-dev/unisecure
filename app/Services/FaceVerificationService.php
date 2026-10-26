<?php

namespace App\Services;

use App\Contracts\FaceVerificationInterface;
use App\Contracts\FaceVerificationResult;
use App\Models\StudentFaceProfile;

class FaceVerificationService
{
    public function __construct(private FaceVerificationInterface $provider) {}

    public function verify(string $capture, StudentFaceProfile $profile): FaceVerificationResult
    {
        if (! $this->provider->available()) {
            return FaceVerificationResult::unavailable();
        }

return $this->provider->verify($capture, $profile);
    }

    public function available(): bool
    {
        return $this->provider->available();
    }
}
