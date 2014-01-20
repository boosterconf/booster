var SpeakModel = Backbone.Model.extend({

    parse: function(response) {
        response.users = new Users(response.users);

        return response;
    }

});