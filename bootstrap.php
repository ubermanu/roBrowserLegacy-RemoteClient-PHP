<?php

/**
 * Application bootstrap: registers class autoloading.
 *
 * Uses the Composer autoloader when available (composer install),
 * and falls back to a minimal PSR-4 autoloader so the project also
 * runs from a bare checkout without Composer.
 */

if (is_file(__DIR__ . '/vendor/autoload.php')) {
    require __DIR__ . '/vendor/autoload.php';
    return;
}

spl_autoload_register(function ($class) {
    $prefix = 'RoBrowser\\RemoteClient\\';

    if (strncmp($class, $prefix, strlen($prefix)) !== 0) {
        return;
    }

    $file = __DIR__ . '/src/' . str_replace('\\', '/', substr($class, strlen($prefix))) . '.php';

    if (is_file($file)) {
        require $file;
    }
});

// Function files (not autoloadable via PSR-4)
require __DIR__ . '/src/Bmp.php';
