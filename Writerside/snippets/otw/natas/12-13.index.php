<?php

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
