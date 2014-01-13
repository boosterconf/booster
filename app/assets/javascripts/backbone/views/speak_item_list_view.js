var SpeakItemListView = Backbone.View.extend({

    // Renders view
    render: function() {
        var html = '';
        _.each(this.collection.models,function(model,index,list) {

            // TODO: Create model view
            var item_html =
                '<div id="speak_box" draggable="true" class="draggable">' +
                '<h5>' + model.get('title') + '</h5>' +
                    '<h6>' + "----" + '</h6>' +
                    '</div>';
            html = html + '<li>' + item_html + '</li>';
        });

        html = '<ul>' + html + '</ul>';

        this.$el.html(html);
        return this;
    }
});