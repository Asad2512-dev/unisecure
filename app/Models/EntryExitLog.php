<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EntryExitLog extends Model
{
    protected $fillable = ['student_id', 'gate_id', 'nfc_card_id', 'guard_id', 'action', 'verification_method', 'event_at', 'reason', 'device_id', 'metadata'];

    protected $casts = ['event_at' => 'datetime', 'metadata' => 'array'];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function gate()
    {
        return $this->belongsTo(Gate::class);
    }

    public function nfcCard()
    {
        return $this->belongsTo(NfcCard::class);
    }

    public function guardUser()
    {
        return $this->belongsTo(Guard::class, 'guard_id');
    }
}
