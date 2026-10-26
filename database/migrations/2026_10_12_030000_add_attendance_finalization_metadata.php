<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('class_sessions', function (Blueprint $t) {
            $t->timestamp('finalized_at')->nullable()->after('status');
            $t->foreignId('finalized_by')->nullable()->after('finalized_at')->constrained('users')->nullOnDelete();
            $t->index(['status', 'finalized_at']);
        });
    }

    public function down(): void
    {
        Schema::table('class_sessions', fn (Blueprint $t) => $t->dropForeign(['finalized_by'])->dropIndex(['status', 'finalized_at'])->dropColumn(['finalized_at', 'finalized_by']));
    }
};
