<?php

declare(strict_types=1);

namespace App\Jobs;

use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Contracts\Cache\Repository as CacheRepository;

/**
 * @internal   Just for a test
 * @deprecated Remove this class
 */
class TestJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * @var string Cache key name
     */
    private string $key;

    /**
     * Create a new job instance.
     *
     * @param string $key
     *
     * @return void
     */
    public function __construct(string $key)
    {
        $this->key = $key;
    }

    /**
     * Execute the job.
     *
     * @param CacheRepository $cache
     *
     * @return void
     */
    public function handle(CacheRepository $cache): void
    {
        $cache->put($this->key, true, Carbon::now()->addMinute()->toDateTimeImmutable());
    }
}
