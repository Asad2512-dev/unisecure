<?php

namespace App\Support;

use Symfony\Component\HttpFoundation\StreamedResponse;

class CsvExport
{
    public static function response(string $filename, array $headers, iterable $rows): StreamedResponse
    {
        return response()->streamDownload(function () use ($headers, $rows): void {
            $out = fopen('php://output', 'w');
            fputcsv($out, $headers);
            foreach ($rows as $row) {
                fputcsv($out, array_map([self::class, 'cell'], (array) $row));
            } fclose($out);
        }, $filename, ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    public static function cell(mixed $value): string
    {
        $value = (string) ($value ?? '');

        return preg_match('/^[\x00-\x20]*[=+\-@]/', $value) ? "'".$value : $value;
    }
}
