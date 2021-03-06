# whoosh
![whoosh header](img/header.png)

*whoosh* is a virtual queueing app for restaurants. *whoosh* takes a group of diners into a queue upon their arrival, and maintains a digital representation of the queue. Diners enter the queue by scanning a unique QR code for the restaurant. Diners can then view the queue in real time and are notified when they should enter. Restaurant managers can manage the waitlist, alerting and removing queuers as necessary.

Restaurants are able to sign up with *whoosh* to create virtual queues for their restaurants, and diners will
scan a QR code to enter this queues. Restaurant managers can then virtually manage the queue.


## Accessing the web app <img src="img/party.png" alt="Red monster in party hat with confetti" width="100" />

### As a restaurant manager
You may access the restaurant-side website via https://whoosh-frontend-deploy.pages.dev/#/ and then click “get started”. Afterwards, you may register a new account or log in with an existing account. We have made an account populated with several queue groups for testing purposes. (Note: due to server cold-start, you may need to wait around 10 seconds for initial log-in)

Test account email: dintaifung@mail.com

Test account password: dintaifung

### As a diner
You may scan the QR code below using your phone camera, or access the website to join the queue via https://whoosh-frontend-deploy.pages.dev/#/joinQueue?restaurant_id=5

<img src="img/test_qr_code.png" alt="test QR code" width="300" />


## Members <img src="img/data.png" alt="Green monster with posters of data analytics" width="100" />
Ho Hol Yin A0136217L

In charge of initialising the Flutter project and creating common widgets to be used throughout the code. Also responsible for the frontend implementation of the queue screens, as well as organising code structure to ensure that code was clean and maintainable. Integrated Flare actors with controlled animations in the site. Added Firebase Analytics to the website.

Liu Zechu A0188295L

In charge of implementing the backend server to provide API endpoints for the application, and implementing the frontend website screens for restaurant managers. Also integrated JSON Web Token for server authentication and Firebase Authentication for user (restaurant manager) authentication.

Yanch Ong A0190353J

In charge of User Interface and User Experience Design. Collected brief user feedback on designs. Conceptualised and created monster assets. Created animations and dynamic elements in Flare Flutter. Handled marketing of the app—from creating marketing assets to writing the pitch.
