const fsPromises = require("fs").promises;

module.exports.handler = async (event, context) => {
	const html = await fsPromises.readFile("index.html", {encoding: "utf8"});

	return {
		statusCode: 200,
		headers: {
			"Content-Type": "text/html",
		},
		body: html,
	};
};

