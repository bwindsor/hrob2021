$(document).ready(function() {
	$("[data-lightbox]").fancybox({
		loop: false,
		caption: function(instance, item) {
			var caption = $(this).find('img').attr('alt') || '';

			if (item.type === 'image') {
				caption = (caption.length ? caption + '<br />' : '') + '<a href="' + item.src + '">Stáhnout obrázek</a>' ;
			}

			return caption;
		}
	});
});
