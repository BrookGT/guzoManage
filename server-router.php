<?php
/**
 * Development router for PHP's built-in server.
 * Mirrors LocalValetDriver.php routing (Apache .htaccess on production).
 *
 * Usage: php -S localhost:8000 server-router.php
 */

$sitePath = __DIR__;
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';

$_SERVER['DOCUMENT_ROOT'] = $sitePath;

// Serve existing files directly (static assets)
$filePath = $sitePath . $uri;
if ($uri !== '/' && is_file($filePath)) {
    return false;
}

// Block sensitive paths (mirror .htaccess)
$blocked = ['/.ai/', '/.git/', '/scripts/', '/vendor/', '/node_modules/', '/docs/'];
foreach ($blocked as $prefix) {
    if (str_starts_with($uri, $prefix)) {
        http_response_code(403);
        exit('Forbidden');
    }
}

function route(string $sitePath, string $uri): ?string
{
    if (preg_match('#^/_studio/api/#', $uri)) {
        $_SERVER['REQUEST_URI'] = $uri;
        return $sitePath . '/_studio/api/router.php';
    }

    if ($uri === '/_studio/install.php' || $uri === '/_studio/install') {
        return $sitePath . '/_studio/install.php';
    }

    if (str_starts_with($uri, '/_studio/') || $uri === '/_studio') {
        return $sitePath . '/_studio/index.php';
    }

    if ($uri === '/' || $uri === '') {
        return is_file($sitePath . '/index.php')
            ? $sitePath . '/index.php'
            : $sitePath . '/_studio/data/default-index.php';
    }

    if ($uri === '/submit.php') {
        return $sitePath . '/submit.php';
    }
    if ($uri === '/mcp.php') {
        return $sitePath . '/mcp.php';
    }

    $cleanPath = ltrim($uri, '/');
    if ($cleanPath) {
        if (is_file($sitePath . '/' . $cleanPath)) {
            return $sitePath . '/' . $cleanPath;
        }
        if (is_file($sitePath . '/' . $cleanPath . '.php')) {
            return $sitePath . '/' . $cleanPath . '.php';
        }
        if (is_file($sitePath . '/' . $cleanPath . '.html')) {
            return $sitePath . '/' . $cleanPath . '.html';
        }
    }

    return is_file($sitePath . '/index.php')
        ? $sitePath . '/index.php'
        : $sitePath . '/_studio/data/default-index.php';
}

$front = route($sitePath, $uri);
if ($front) {
    require $front;
    return true;
}

http_response_code(404);
echo 'Not Found';
return true;
