import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 50 },
    { duration: '20s', target: 100 },
    { duration: '20s', target: 30 },
    { duration: '10s', target: 2 },
  ],

  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
    checks: ['rate>0.99'],
  },
};

const BASE_URL = 'http://app:5000';
const AVAILABLE_PRODUCTS = [1, 2, 3, 4, 5, 6, 7];

function randomProductId() {
  return AVAILABLE_PRODUCTS[
    Math.floor(Math.random() * AVAILABLE_PRODUCTS.length)
  ];
}

export default function () {

  // -------------------------
  // Browse homepage. 100% of users
  // -------------------------

  let response = http.get(`${BASE_URL}/`);

  check(response, {
    'homepage returns 200': (r) => r.status === 200,
  });

  sleep(Math.random() * 2 + 1);


  // -------------------------
  // Browse cart. 80% of users
  // -------------------------

  if (Math.random() < 0.80) {
    response = http.get(`${BASE_URL}/cart`);

    check(response, {
      'cart returns 200': (r) => r.status === 200,
    });

    sleep(Math.random() * 2 + 1);
  }


  // -------------------------
  // Add product to cart. 50% of users
  // -------------------------

  const cartProductId = randomProductId();

  if (Math.random() < 0.50) {

    response = http.post(
      `${BASE_URL}/cart/add/${cartProductId}`,
      null,
      { redirects: 0 }
    );

    check(response, {
      'product added to cart': (r) =>
        r.status >= 300 && r.status < 400,
    });

    sleep(Math.random() * 2 + 1);


    // -------------------------
    // Increase quantity. 30% of users
    // -------------------------

    if (Math.random() < 0.30) {

      response = http.post(
        `${BASE_URL}/cart/increase/${cartProductId}`,
        null,
        { redirects: 0 }
      );

      check(response, {
        'cart quantity increased': (r) =>
          r.status >= 300 && r.status < 400,
      });

      sleep(Math.random() * 2 + 1);
    }


    // -------------------------
    // Decrease quantity. 20% of users
    // -------------------------

    if (Math.random() < 0.20) {

      response = http.post(
        `${BASE_URL}/cart/decrease/${cartProductId}`,
        null,
        { redirects: 0 }
      );

      check(response, {
        'cart quantity decreased': (r) =>
          r.status >= 300 && r.status < 400,
      });

      sleep(Math.random() * 2 + 1);
    }


    // -------------------------
    // Remove product. 20% of users
    // -------------------------

    if (Math.random() < 0.20) {

      response = http.post(
        `${BASE_URL}/cart/remove/${cartProductId}`,
        null,
        { redirects: 0 }
      );

      check(response, {
        'product removed from cart': (r) =>
          r.status >= 300 && r.status < 400,
      });

      sleep(Math.random() * 2 + 1);
    }
  }


  // -------------------------
  // Wishlist. 30% of users
  // -------------------------

  if (Math.random() < 0.30) {

    response = http.get(`${BASE_URL}/wishlist`);

    check(response, {
      'wishlist returns 200': (r) => r.status === 200,
    });

    sleep(Math.random() * 2 + 1);


    const wishlistProductId = randomProductId();


    // -------------------------
    // Add to wishlist. 15% of users
    // -------------------------

    if (Math.random() < 0.50) {

      response = http.post(
        `${BASE_URL}/wishlist/add/${wishlistProductId}`,
        null,
        { redirects: 0 }
      );

      check(response, {
        'product added to wishlist': (r) =>
          r.status >= 300 && r.status < 400,
      });

      sleep(Math.random() * 2 + 1);


      // -------------------------
      // Remove from wishlist. 50% of wishlist users
      // -------------------------

      if (Math.random() < 0.50) {

        response = http.post(
          `${BASE_URL}/wishlist/remove/${wishlistProductId}`,
          null,
          { redirects: 0 }
        );

        check(response, {
          'product removed from wishlist': (r) =>
            r.status >= 300 && r.status < 400,
        });

        sleep(Math.random() * 2 + 1);
      }
    }
  }


  // -------------------------
  // Application health. 100% of users
  // -------------------------

  response = http.get(`${BASE_URL}/health`);

  check(response, {
    'application is healthy': (r) =>
      r.status === 200 &&
      r.body.includes('"status":"healthy"'),
  });

  sleep(1);


  // -------------------------
  // Database health. 20% of users
  // -------------------------

  if (Math.random() < 0.20) {

    response = http.get(`${BASE_URL}/health/db`);

    check(response, {
      'database is reachable': (r) =>
        r.status === 200 &&
        r.body.includes('"database":"reachable"'),
    });

    sleep(1);
  }
}