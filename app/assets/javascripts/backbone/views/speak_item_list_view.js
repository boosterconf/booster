var SpeakItemListView = Backbone.View.extend({

    // HTML element name, where to render a view.
    el: '#speaks_listing',

    initialize: function() {
        this.collection = new SpeakCollection;
        this.collection.fetch({reset: true}); // NEW
        this.render();
    },

    // Render view.
    render: function() {
        var html = '';
        console.log(this.collection.models);
        _.each(this.collection.models,function(model,index,list) {
            var item_html =
                '<div id="speak_box" draggable="true" class="draggable">' +
                '<h4>' + model.get('title') + '</h4>' +
                    '<h6>' + "----" + '</h6>' +
                    '</div>'
            html = html + '<li>' + item_html + '</li>';
        });

        html = '<ul>' + html + '</ul>';

        // Set html for the view element using jQuery.
        $(this.el).html(html);
    }
});