const fsPromises = require("fs").promises;
const mustache = require("mustache");

module.exports.handler = async (event, context) => {
	const template = await fsPromises.readFile("index.mustache", {encoding: "utf8"});
	const html = mustache.render(template, {what: "World"});

	return {
		statusCode: 200,
		headers: {
			"Content-Type": "text/html",
		},
		body: html,
	};
};

