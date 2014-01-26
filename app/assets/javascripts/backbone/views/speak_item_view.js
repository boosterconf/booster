var SpeakItemView = Backbone.View.extend({


    initialize: function() {
        this.$el.attr('draggable', true);
        this.$el.addClass('draggable');

        this.$el.draggable({
            revert: "invalid",
            cursor: "move"
        });

    },

    // Renders view
    render: function () {
        var speaker = this.model.get('users').first();

        var html =
                '<h5>' + this.model.get('title') + '</h5>' +
                '<h6>' + speaker.get('name') + ' (' + speaker.get('company') + ')' + '</h6>';

        this.$el.append(html);

        return this;
    }
});