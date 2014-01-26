var SpeakItemView = Backbone.View.extend({

    tagName: 'li',

    // Renders view
    render: function () {
        console.log("In view");
        var speaker = this.model.get('users').first();

        console.log("this.$el in itemview: " + this.$el);

        var html =
            '<div draggable="true" class="draggable">' +
                '<h5>' + this.model.get('title') + '</h5>' +
                '<h6>' + speaker.get('name') + ' (' + speaker.get('company') + ')' + '</h6>' +
                '</div>';

        this.$el.append(html);

        return this;
    }
});