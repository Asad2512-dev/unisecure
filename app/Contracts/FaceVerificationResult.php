<?php
namespace App\Contracts;
final class FaceVerificationResult { public function __construct(public readonly string $status,public readonly ?int $studentId=null,public readonly ?string $code=null){} public function verified():bool{return $this->status==='verified'&&$this->studentId!==null;} public static function unavailable():self{return new self('provider_unavailable',null,'FACE_SERVICE_UNAVAILABLE');} public static function noMatch():self{return new self('no_match',null,'FACE_NO_MATCH');} }
