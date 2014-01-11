var SpeakCollection = Backbone.Collection.extend
({
    model: SpeakModel,
    url: '/talks'
});