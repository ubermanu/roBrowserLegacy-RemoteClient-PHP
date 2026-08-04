<?php

/**
 * Application bootstrap: registers class autoloading.
 *
 * The project has no external dependencies, so a minimal PSR-4 autoloader
 * for the RoBrowser\RemoteClient namespace is all that is needed.
 */

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
