<?php

namespace Tests\Feature;

use App\Models\Student;
use App\Services\AttendanceReportService;
use App\Support\CsvExport;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PhaseEightReportingTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_empty_student_report_has_zero_denominator_and_no_fabricated_percentage(): void
    {
        $student = new Student(['section_id' => 999]);
        $summary = app(AttendanceReportService::class)->studentSummary($student, '2099-01-01', '2099-01-31');
        $this->assertSame(0, $summary['eligible_sessions']);
        $this->assertNull($summary['percentage']);
        $this->assertSame(0, $summary['attended']);
    }

    public function test_analytics_is_admin_only_and_csv_stream_contains_escaped_cells(): void
    {
        $this->get('/admin/reports/analytics')->assertRedirect('/login');
        $response = CsvExport::response('test.csv', ['value'], [['=SUM(A1)'], ['+cmd'], ['-formula'], ['@lookup'], [" \t=hidden"], ['ordinary'], [-12]]);
        ob_start();
        $response->sendContent();
        $csv = ob_get_clean();
        $this->assertStringContainsString("'=SUM(A1)", $csv);
        $this->assertStringContainsString("'+cmd", $csv);
        $this->assertStringContainsString("'-formula", $csv);
        $this->assertStringContainsString("'@lookup", $csv);
        $this->assertStringContainsString("' \t=hidden", $csv);
        $this->assertStringContainsString('ordinary', $csv);
        $this->assertStringContainsString('-12',$csv);
    }
}
