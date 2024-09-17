<?php

$cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg=";
$arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");

$json_encode = json_encode($arr);
$base64_decode = base64_decode($cookie);

for ($i = 0; $i < strlen($json_encode); $i++) {
    echo $json_encode[$i] ^ $base64_decode[$i];
}

function testKey(): bool {
    $cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg=";
    $arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");
    $json_encode = json_encode($arr);
    $base64_decode = base64_decode($cookie);

    return xor_encrypt($base64_decode) === $json_encode;
}

var_dump(testKey());

$arr = array("showpassword"=>"yes","bgcolor"=>"#ffffff");
$json = json_encode($arr);
$xor = xor_encrypt($json);
$cookie = base64_encode($xor);

echo $cookie;