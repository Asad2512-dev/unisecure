<?php
namespace App\Services;
use App\Contracts\{FcmDeliveryInterface,FcmDeliveryResult};
class UnavailableFcmProvider implements FcmDeliveryInterface { public function available():bool{return false;} public function send(string $token,array $data):FcmDeliveryResult{return FcmDeliveryResult::unavailable();} }
