/**
 * reveal-header
 * A filter that adds header text and logo.
 * 
 * MIT License
 * Copyright (c) 2023-2024 Shafayet Khan Shafee.
 */

function header() {

  // Store section hierarchy
  let presentationTitle = '';
  let currentH1Section = '';

  // add the header structure as the firstChild of div.reveal-header
  function add_header() {
    let header = document.querySelector("div.reveal-header");
    let reveal = document.querySelector(".reveal");
    reveal.insertBefore(header, reveal.firstChild);

    let header_title_p_placeholder = document.querySelector('div.header-title > p');
    let header_title_h2_placeholder = document.createElement('div');
    header_title_h2_placeholder.className = 'breadcrumb-container';
    header_title_p_placeholder.replaceWith(header_title_h2_placeholder);

    logo_img = document.querySelector('.header-logo > img');
    if (logo_img?.getAttribute('src') == null) {
      if (logo_img?.getAttribute('data-src') != null) {
        logo_img.src = logo_img?.getAttribute('data-src') || "";
        logo_img.removeAttribute('data-src');
      };
    };

    // Store presentation title from title slide
    let title = document.querySelector('#title-slide .title, .quarto-title-block .title, h1.title');
    if (title) {
      presentationTitle = title.textContent;
    }
  };


  function make_h2_title() {
    let currentSlide = Reveal.getCurrentSlide();
    let header_title_placeholder = document.querySelector('div.header-title > .breadcrumb-container');
    let header_div = document.querySelector('div.reveal-header');

    if(currentSlide.id == 'title-slide' || currentSlide.classList.contains('title-slide')) {
      header_div.style.visibility = 'hidden';
      return;
    }

    // Update hierarchy based on slide content
    let h1 = currentSlide.querySelector('h1');

    // Update stored hierarchy when new headers are found
    if (h1) {
      currentH1Section = h1.textContent;
    }

    // Build breadcrumb HTML
    let breadcrumbHTML = '';
    if (presentationTitle) {
      breadcrumbHTML += `<div class="breadcrumb-line level-1">${presentationTitle}</div>`;
    }
    if (currentH1Section) {
      breadcrumbHTML += `<div class="breadcrumb-line level-2">└─${currentH1Section}</div>`;
    }

    header_title_placeholder.innerHTML = breadcrumbHTML;
    header_div.style.visibility = 'visible';
  };
  
  
  function linkify_logo(logo, href) {
    const logo_cloned = logo.cloneNode(true);
    const link = document.createElement('a');
    link.href = href;
    link.target = '_blank';
    link.appendChild(logo_cloned);
    logo.replaceWith(link);
  };
    
  function get_clean_attrs(elem, attrName) {
    let attrVal = elem.getAttribute(attrName);
    if (attrVal != null) {
     elem.removeAttribute(attrName); 
    }
    return attrVal;
  };
  
  
  if (Reveal.isReady()) {
    add_header();
    
    const slides = Reveal.getSlides();
    slides.forEach(slide => {
      const h2Element = slide.querySelector('h2');

      if (h2Element) {
        const h2Text = h2Element.textContent;
        slide.setAttribute('data-h2-text', h2Text);
      } else {
        slide.setAttribute('data-h2-text', '');
      };
  });
    
    make_h2_title();
    
    /*************** linkifying the header and footer logo ********************/
    const header_logo = document.querySelector('div.header-logo');
    if (header_logo != null) {
      const header_logo_link = get_clean_attrs(header_logo, 'data-header-logo-link');
      const footer_logo_link = get_clean_attrs(header_logo, 'data-footer-logo-link');
      
      if (header_logo_link != null) {
        const header_logo_img = document.querySelector('div.header-logo').firstElementChild;
        linkify_logo(header_logo_img, header_logo_link);
      };
      
    };
    /****************************** END ***************************************/
    
    Reveal.on( 'slidechanged', event => {
      make_h2_title();
    });
    
  };
};


window.addEventListener("load", (event) => {
  header();
});
