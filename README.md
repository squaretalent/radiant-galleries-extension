= Galleries

Galleries with Items, items have an Image which is just an asset from paperclipped.

== Requirements

**MUST**

* Radiant 0.9.0 
* *gem* Paperclip
* *ext* Paperclipped

**COULD**

* *gem* aws-s3
* Gallery Layout
* GalleryItem Layout

== Usage Methods

**Gallery Page**

* Create Gallery
* Change page type to Gallery
* Select appropriate Gallery
* Select appropriate layout

    /url/to/page

**Galleries Routes**

* Create Gallery

    /gallery/:gallery_handle

**Gallery Items Routes**

* Create Gallery
* Add Items

    /gallery/:gallery_handle/:item_handle

== Todo

* tests (-:
* create gallery / item interface
* validate handle uniqueness within scope of gallery