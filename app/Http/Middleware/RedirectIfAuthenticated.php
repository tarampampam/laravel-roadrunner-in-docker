<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Providers\RouteServiceProvider;
use Symfony\Component\HttpFoundation\Response;

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param Request                       $request
     * @param \Closure(Request): (Response) $next
     * @param string                        ...$guards
     *
     * @return Response
     */
    public function handle(Request $request, Closure $next, string ...$guards): Response
    {
        $guards = empty($guards) ? [null] : $guards;

        foreach ($guards as $guard) {
            if (Auth::guard($guard)->check()) {
                /** @var \Illuminate\Http\RedirectResponse $redirect */
                $redirect = redirect(RouteServiceProvider::HOME);

                return $redirect;
            }
        }

        return $next($request);
    }
}
