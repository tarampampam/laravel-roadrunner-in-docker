<?php

namespace Tests\Unit;

use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_that_true_is_true(): void
    {
        $this->assertTrue(true);

        \rr\dump($this->app['env']);

        \rr\dump($this->app->environment(), $_ENV['APP_ENV']);
    }
}
