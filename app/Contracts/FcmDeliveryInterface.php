<?php
namespace App\Contracts;
interface FcmDeliveryInterface { public function available():bool; public function send(string $token,array $data):FcmDeliveryResult; }
