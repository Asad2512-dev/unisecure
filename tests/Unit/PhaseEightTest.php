<?php

namespace Tests\Unit;

use App\Services\UnavailableFcmProvider;
use App\Support\CsvExport;
use Tests\TestCase;

class PhaseEightTest extends TestCase
{
    public function test_csv_formula_prefixes_are_escaped(): void
    {
        foreach (['=SUM(A1)', '+cmd', '-danger', '@lookup'] as $value) {
            $this->assertSame("'{$value}", CsvExport::cell($value));
        }
    }

    public function test_csv_safe_values_are_unchanged_and_null_is_empty(): void
    {
        $this->assertSame('student-1', CsvExport::cell('student-1'));
        $this->assertSame('', CsvExport::cell(null));
    }

    public function test_fcm_unavailable_provider_never_accepts_delivery(): void
    {
        $result = (new UnavailableFcmProvider)->send('not-a-real-token', ['notification_id' => 'test']);
        $this->assertFalse($result->accepted);
        $this->assertSame('provider_unavailable', $result->errorCategory);
    }

    public function test_admin_notification_pages_are_protected(): void
    {
        $this->get('/admin/notifications')->assertRedirect('/login');
        $this->get('/admin/notifications/example')->assertRedirect('/login');
    }
}
