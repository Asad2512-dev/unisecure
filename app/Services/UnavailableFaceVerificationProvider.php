<?php
namespace App\Services;
use App\Contracts\{FaceVerificationInterface,FaceVerificationResult};
use App\Models\StudentFaceProfile;
class UnavailableFaceVerificationProvider implements FaceVerificationInterface { public function available():bool{return false;} public function verify(string $capture,StudentFaceProfile $profile):FaceVerificationResult{return FaceVerificationResult::unavailable();} }
