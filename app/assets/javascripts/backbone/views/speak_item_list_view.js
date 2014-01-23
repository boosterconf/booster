var SpeakItemListView = Backbone.View.extend({

    // Renders view
    render: function() {
        var html = '';
        _.each(this.collection.models, function(model, index, list) {

            var speaker = model.get('users').first()
            // TODO: Create model view
            var item_html =
                '<div draggable="true" class="draggable">' +
                '<h5>' + model.get('title') + '</h5>' +
                    '<h6>' + speaker.get('name') + ' (' + speaker.get('company') + ')' + '</h6>' +
                    '</div>';
            html = html + '<li>' + item_html + '</li>';
        });

        html = '<ul>' + html + '</ul>';

        this.$el.html(html);
        return this;
    }
});