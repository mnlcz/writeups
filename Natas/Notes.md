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
