<?php

namespace App\Contracts;

use App\Models\StudentFaceProfile;

interface FaceVerificationInterface
{
    public function available(): bool;

    public function verify(string $capture, StudentFaceProfile $profile): FaceVerificationResult;
}
