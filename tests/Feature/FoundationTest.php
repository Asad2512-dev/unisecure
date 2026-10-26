<?php

namespace Tests\Feature;

use Tests\TestCase;

class FoundationTest extends TestCase
{
    public function test_application_responds_successfully(): void
    {
        $this->get('/')->assertOk();
    }

    public function test_api_health_uses_versioned_route_and_envelope(): void
    {
        $this->getJson('/api/v1/health')->assertOk()->assertJsonPath('success', true)->assertHeader('X-Request-ID');
    }

    public function test_protected_api_route_rejects_guests(): void
    {
        $this->getJson('/api/v1/me')->assertUnauthorized();
    }

    public function test_admin_dashboard_requires_authentication(): void
    {
        $this->get('/admin')->assertRedirect('/login');
    }
}
